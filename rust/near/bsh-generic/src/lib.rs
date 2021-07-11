//! BSH Generic Contract

#![forbid(
    arithmetic_overflow,
    mutable_transmutes,
    no_mangle_const_items,
    unknown_crate_types
)]
#![warn(
    bad_style,
    deprecated,
    improper_ctypes,
    non_shorthand_field_patterns,
    overflowing_literals,
    stable_features,
    unconditional_recursion,
    unknown_lints,
    unused,
    unused_allocation,
    unused_attributes,
    unused_comparisons,
    unused_features,
    unused_parens,
    unused_variables,
    while_true,
    clippy::unicode_not_nfc,
    clippy::wrong_pub_self_convention,
    clippy::unwrap_used,
    trivial_casts,
    trivial_numeric_casts,
    unused_extern_crates,
    unused_import_braces,
    unused_qualifications,
    unused_results
)]

mod bsh_types;
pub use bsh_types::*;

use btp_common::BTPAddress;
use near_sdk::borsh::{self, BorshDeserialize, BorshSerialize};
use near_sdk::serde::{Deserialize, Serialize};
use near_sdk::{env, metadata, near_bindgen, setup_alloc};
use std::collections::HashMap;

setup_alloc!();
metadata! {
    /// BSH Generic contract is used to handle communications
    /// among BMC Service and a BSH core contract.
    /// This struct implements `Default`: https://github.com/near/near-sdk-rs#writing-rust-contract
    #[near_bindgen]
    #[derive(BorshDeserialize, BorshSerialize, Clone, Debug, Default, Deserialize, Serialize)]
    #[serde(crate = "near_sdk::serde")]
    pub struct BshGeneric {
        bmc_contract: String,
        bsh_contract: String,
        /// A list of transferring requests
        /// Use `HashMap` because `LookupMap` doesn't implement
        /// Clone, Debug, and Default traits
        requests: HashMap<u64, PendingTransferCoin>,
        /// BSH Service name
        service_name: String,
        /// A counter of sequence number of service message
        serial_no: u64,
        num_of_pending_requests: u64,
    }
}

#[near_bindgen]
impl BshGeneric {
    pub const RC_OK: u64 = 0;
    pub const RC_ERR: u64 = 1;

    #[init]
    pub fn new(bmc: &str, bsh_contract: &str, service_name: &str) -> Self {
        // TODO: fully implement after BMC and BSH core contracts are written

        Self {
            bmc_contract: bmc.to_string(),
            bsh_contract: bsh_contract.to_string(),
            requests: HashMap::new(),
            service_name: service_name.to_string(),
            serial_no: 0,
            num_of_pending_requests: 0,
        }
    }

    /// Check whether BSH has any pending transferring requests
    pub fn has_pending_requests(&self) -> Result<bool, &str> {
        Ok(self.num_of_pending_requests != 0)
    }

    /// Send Service Message from BSH contract to BMCService contract
    pub fn send_service_message(
        &mut self,
        from: &str,
        to: &str,
        coin_names: Vec<String>,
        values: Vec<u64>,
        fees: Vec<u64>,
    ) -> Result<(), &str> {
        let btp_addr = BTPAddress(to.to_string());
        let _network_addr = btp_addr
            .network_address()
            .expect("Failed to retrieve network address")
            .as_str();
        let _contract_addr = btp_addr
            .contract_address()
            .expect("Failed to retrieve contract address")
            .as_str();

        let mut assets: Vec<Asset> = Vec::with_capacity(coin_names.len());
        let mut asset_details: Vec<AssetTransferDetail> = Vec::with_capacity(coin_names.len());

        for i in 0..coin_names.len() {
            assets.push(Asset {
                coin_name: coin_names[i].clone(),
                value: values[i],
            });
            asset_details.push(AssetTransferDetail {
                coin_name: coin_names[i].clone(),
                value: values[i],
                fee: fees[i],
            });
        }
        // Send Service Message to BMC
        // BMC: bmc.send_message();

        // Push pending transactions into Record list
        let pending_transfer_coin = PendingTransferCoin {
            from: from.to_string(),
            to: to.to_string(),
            coin_names: coin_names.clone(),
            amounts: values.clone(),
            fees: fees.clone(),
        };
        let _ = self
            .requests
            .insert(self.serial_no, pending_transfer_coin)
            .expect("Failed to insert request");
        self.num_of_pending_requests += 1;
        let bsh_event = BshEvents::TransferStart {
            from,
            to,
            sn: self.serial_no,
            asset_details: asset_details.clone(),
        };
        let bsh_event = bincode::serialize(&bsh_event).expect("Failed to serialize bsh event");
        env::log(&bsh_event);
        self.serial_no += 1;
        Ok(())
    }

    /// BSH handle BTP Message from BMC contract
    pub fn handle_btp_message(
        &mut self,
        from: &str,
        svc: &str,
        sn: u64,
        msg: &[u8],
    ) -> Result<(), &str> {
        assert_eq!(self.service_name, svc.to_string(), "Invalid Svc");
        let sm: ServiceMessage = bincode::deserialize(msg).expect("Failed to deserialize msg");

        if sm.service_type == ServiceType::RequestCoinRegister {
            let tc: TransferCoin =
                bincode::deserialize(sm.data.as_slice()).expect("Failed to deserialize sm data");
            //  check receiving address whether it is a valid address
            //  or revert if not a valid one
            let btp_addr = BTPAddress(tc.to.clone());
            if let Ok(_) = btp_addr.is_valid() {
                if let Ok(_) = self.handle_request_service(&tc.to, tc.assets) {
                    self.send_response_message(
                        ServiceType::ResponseHandleService,
                        from,
                        sn,
                        "",
                        Self::RC_OK,
                    );
                } else {
                    return Err("InvalidData");
                }
            } else {
                return Err("InvalidBtpAddress");
            }
            self.send_response_message(
                ServiceType::ResponseHandleService,
                from,
                sn,
                "InvalidAddress",
                Self::RC_ERR,
            );
        } else if sm.service_type == ServiceType::ResponseHandleService {
            // Check whether `sn` is pending state
            let req = self.requests.get(&sn).expect("Failed to retrieve request");
            let res = req.from.as_bytes();

            assert_ne!(res.len(), 0, "InvalidSN");
            let response: Response = bincode::deserialize(sm.data.as_slice())
                .expect("Failed to deserialize service message");
            self.handle_response_service(sn, response.code, response.message.as_str())
                .expect("Error in handling response service");
        } else if sm.service_type == ServiceType::UnknownType {
            let bsh_event = BshEvents::UnknownResponse { from, sn };
            let bsh_event = bincode::serialize(&bsh_event).expect("Failed to serialize bsh event");
            env::log(&bsh_event);
        } else {
            // If none of those types above BSH responds with a message of
            // RES_UNKNOWN_TYPE
            self.send_response_message(ServiceType::UnknownType, from, sn, "Unknown", Self::RC_ERR);
        }
        Ok(())
    }

    /// BSH handle BTP Error from BMC contract
    pub fn handle_btp_error(
        &mut self,
        _src: &str,
        svc: &str,
        sn: u64,
        code: u64,
        msg: &str,
    ) -> Result<(), &str> {
        assert_eq!(svc.to_string(), self.service_name, "InvalidSvc");
        let req = self.requests.get(&sn).expect("Failed to retrieve request");
        let res = req.from.as_bytes();
        assert_ne!(res.len(), 0, "InvalidSN");
        self.handle_response_service(sn, code, msg)
            .expect("Error in handling response service");
        Ok(())
    }

    #[private]
    pub fn handle_response_service(&mut self, sn: u64, code: u64, msg: &str) -> Result<(), &str> {
        let req = self.requests.get(&sn).expect("Failed to retrieve request");
        let caller = req.from.as_str();
        let data_len = req.coin_names.len();
        for _i in 0..data_len {
            // BSH core: bsh_core.handle_response_service();
        }

        let _ = self.clone().requests.remove(&sn);
        self.num_of_pending_requests -= 1;
        let bsh_event = BshEvents::TransferEnd {
            from: caller,
            sn,
            code,
            response: msg,
        };
        let bsh_event = bincode::serialize(&bsh_event).expect("Failed to serialize bsh event");
        env::log(&bsh_event);
        Ok(())
    }

    /// Handle a list of minting/transferring coins/tokens
    #[payable]
    pub fn handle_request_service(&mut self, _to: &str, assets: Vec<Asset>) -> Result<(), &str> {
        assert_eq!(
            env::current_account_id(),
            env::signer_account_id(),
            "Unauthorized"
        );
        for _i in 0..assets.len() {
            // BSH core: assert(bsh_core.is_valid_coin(assets[i].coin_name), "UnregisteredCoin");
        }
        // BSH core: if let Ok(_) = bsh_core.mint() {}
        Ok(())
    }

    #[private]
    pub fn send_response_message(
        &mut self,
        _service_type: ServiceType,
        _to: &str,
        _sn: u64,
        _msg: &str,
        _code: u64,
    ) {
        // BMC: bmc.send_message();
    }

    /// BSH handle `Gather Fee Message` request from BMC contract
    /// fa: fee aggregator
    #[payable]
    pub fn handle_fee_gathering(&mut self, fa: &str, svc: &str) -> Result<(), &str> {
        assert_eq!(self.service_name, svc.to_string(), "InvalidSvc");
        //  If adress of Fee Aggregator (fa) is invalid BTP address format
        //  revert(). Then, BMC will catch this error
        let btp_addr = BTPAddress(fa.to_string());
        if let Ok(_) = btp_addr.is_valid() {
            // BSH core: bsh_core.transfer_fees(fa);
        }
        Ok(())
    }
}

#[cfg(not(target_arch = "wasm32"))]
#[cfg(test)]
mod tests {
    use super::*;
    use near_sdk::test_utils::VMContextBuilder;
    use near_sdk::MockedBlockchain;
    use near_sdk::{testing_env, VMContext};
    use std::convert::TryInto;

    fn get_context(is_view: bool) -> VMContext {
        VMContextBuilder::new()
            .signer_account_id("bob_near".try_into().unwrap())
            .is_view(is_view)
            .build()
    }

    #[test]
    fn check_has_pending_request() {
        let context = get_context(false);
        testing_env!(context);
        let bsh = BshGeneric::default();
        let context = get_context(true);
        testing_env!(context);
        assert_eq!(bsh.has_pending_requests().unwrap(), false);
    }

    #[test]
    fn check_send_service_message() {
        let context = get_context(false);
        testing_env!(context);
        let mut bsh = BshGeneric::default();

        let from = "btp://0x1.near/cx77ed9048b594b95199f326fc76e76a9d33dd665b";
        let to = "btp://0x1.near/cx67ed9048b594b95199f326fc76e76a9d33dd665b";
        let coin_names = vec!["btc".to_string(), "ether".to_string(), "usdt".to_string()];
        let values = vec![100, 200, 300];
        let fees = vec![1, 2, 3];

        let context = get_context(true);
        testing_env!(context);
        assert!(bsh
            .send_service_message(from, to, coin_names, values, fees)
            .is_ok());
    }

    #[test]
    fn check_handle_btp_message() {
        let context = get_context(false);
        testing_env!(context);
        let mut bsh = BshGeneric::default();

        let from = "btp://0x1.near/cx77ed9048b594b95199f326fc76e76a9d33dd665b";
        let svc = "";
        let sn = 1;
        let msg = vec![b'1', b'2', b'3'];

        let context = get_context(true);
        testing_env!(context);
        assert!(bsh.handle_btp_message(from, svc, sn, &msg).is_ok());
    }

    #[test]
    fn check_handle_btp_error() {
        let context = get_context(false);
        testing_env!(context);
        let mut bsh = BshGeneric::default();

        let src = "btp://0x1.near/cx77ed9048b594b95199f326fc76e76a9d33dd665b";
        let svc = "";
        let sn = 1;
        let code = 1;
        let msg = "test-msg";

        let context = get_context(true);
        testing_env!(context);
        assert!(bsh.handle_btp_error(src, svc, sn, code, msg).is_ok());
    }

    #[test]
    fn check_handle_response_service() {
        let context = get_context(false);
        testing_env!(context);
        let mut bsh = BshGeneric::default();

        let sn = 1;
        let code = 1;
        let msg = "test-msg";

        let context = get_context(true);
        testing_env!(context);
        assert!(bsh.handle_response_service(sn, code, msg).is_ok());
    }

    #[test]
    fn check_handle_request_service() {
        let context = get_context(false);
        testing_env!(context);
        let mut bsh = BshGeneric::default();

        let btc = Asset {
            coin_name: "btc".to_string(),
            value: 100,
        };
        let ether = Asset {
            coin_name: "ether".to_string(),
            value: 200,
        };
        let usdt = Asset {
            coin_name: "usdt".to_string(),
            value: 300,
        };
        let assets = vec![btc, ether, usdt];
        let to = "btp://0x1.near/cx67ed9048b594b95199f326fc76e76a9d33dd665b";

        let context = get_context(true);
        testing_env!(context);
        assert!(bsh.handle_request_service(to, assets).is_ok());
    }

    #[test]
    fn check_handle_fee_gathering() {
        let context = get_context(false);
        testing_env!(context);
        let mut bsh = BshGeneric::default();

        let fa = "btp://0x1.near/cx77ed9048b594b95199f326fc76e76a9d33dd665b";
        let svc = "";

        let context = get_context(true);
        testing_env!(context);
        assert!(bsh.handle_fee_gathering(svc, fa).is_ok());
    }
}
