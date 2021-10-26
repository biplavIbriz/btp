package substrate

// Because we're trying to build btp as executable, using json assets can't be embbeded,
// So, we put json as string I use them, the origins are from https://github.com/itering/scale.go/tree/master/network
var typesDefinitionMap = map[string]string{
	"moonbase":  `{"Weight":"u64","CompactAssignments":"CompactAssignmentsLatest","RefCount":"u32","Box<<T as Config>::Call>":"Call","AccountInfo":"AccountInfoWithTripleRefCount","DispatchResult":{"type":"enum","type_mapping":[["Ok","Null"],["Error","DispatchError"]]},"TransactionRecoveryId":"U64","TransactionSignature":{"type":"struct","type_mapping":[["v","TransactionRecoveryId"],["r","H256"],["s","H256"]]},"RoundInfo":{"type_mapping":[["current","RoundIndex"],["first","BlockNumber"],["length","u32"]],"type":"struct"},"Candidate":{"type_mapping":[["id","AccountId"],["fee","Perbill"],["bond","Balance"],["nominators","Vec<Bond>"],["total","Balance"],["state","CollatorStatus"]],"type":"struct"},"TxPoolResultStatus":{"type_mapping":[["pending","U256"],["queued","U256"]],"type":"struct"},"CollatorStatus":{"type_mapping":[["Active","NULL"],["Idle","Null"],["Leaving","RoundIndex"]],"type":"enum"},"PoolTransaction":{"type_mapping":[["hash","H256"],["nonce","U256"],["block_hash","Option<H256>"],["block_number","Option<U256>"],["from","H160"],["to","Option<H160>"],["value","U256"],["gas_price","U256"],["gas","U256"],["input","Bytes"]],"type":"struct"},"ExtrinsicSignature":"EthereumSignature","Collator":{"type_mapping":[["id","AccountId"],["bond","Balance"],["nominators","Vec<Bond>"],["total","Balance"],["state","CollatorStatus"]],"type":"struct"},"CollatorSnapshot":{"type_mapping":[["bond","Balance"],["nominators","Vec<Bond>"],["total","Balance"]],"type":"struct"},"Address":"AccountId","SystemInherentData":{"type_mapping":[["validation_data","PersistedValidationData"],["relay_chain_state","StorageProof"],["downward_messages","Vec<InboundDownwardMessage>"],["horizontal_messages","BTreeMap<ParaId, Vec<InboundHrmpMessage>>"]],"type":"struct"},"OrderedSet":"Vec<Bond>","AccountId":"EthereumAccountId","Account":{"type_mapping":[["nonce","U256"],["balance","u128"]],"type":"struct"},"LookupSource":"AccountId","InflationInfo":{"type_mapping":[["expect","RangeBalance"],["round","RangePerbill"]],"type":"struct"},"Summary":"Bytes","Range":"RangeBalance","TxPoolResultInspect":{"type_mapping":[["pending","HashMap<H160, HashMap<U256, Summary>>"],["queued","HashMap<H160, HashMap<U256, Summary>>"]],"type":"struct"},"RangeBalance":{"type_mapping":[["min","Balance"],["ideal","Balance"],["max","Balance"]],"type":"struct"},"RoundIndex":"u32","Nominator":{"type_mapping":[["nominations","Vec<Bond>"],["total","Balance"]],"type":"struct"},"Balance":"u128","Bond":{"type_mapping":[["owner","AccountId"],["amount","Balance"]],"type":"struct"},"RangePerbill":{"type_mapping":[["min","Perbill"],["ideal","Perbill"],["max","Perbill"]],"type":"struct"},"TxPoolResultContent":{"type_mapping":[["pending","HashMap<H160, HashMap<U256, PoolTransaction>>"],["queued","HashMap<H160, HashMap<U256, PoolTransaction>>"]],"type":"struct"},"AuthorId":"AccountId32","RegistrationInfo":{"type_mapping":[["account","AccountId"],["deposit","Balance"]],"type":"struct"},"AssetRegistrarMetadata":{"type_mapping":[["name","Vec<u8>"],["symbol","Vec<u8>"],["decimals","u8"],["is_frozen","bool"]],"type":"struct"},"Collator2":{"type_mapping":[["id","AccountId"],["bond","Balance"],["nominators","Vec<AccountId>"],["top_nominators","Vec<Bond>"],["bottom_nominators","Vec<Bond>"],["total_counted","Balance"],["total_backing","Balance"],["state","CollatorStatus"]],"type":"struct"},"NominatorAdded":{"type":"enum","type_mapping":[["AddedToTop","Balance"],["AddedToBottom","Null"]]},"CurrencyId":{"type":"enum","type_mapping":[["SelfReserve","Null"],["OtherReserve","u128"]]},"AssetType":{"type":"enum","type_mapping":[["Xcm","MultiLocation"]]},"RelayChainAccountId":"AccountId32","AssetInstance":"AssetInstanceV0","MultiAsset":"MultiAssetV0","Xcm":"XcmV0","XcmOrder":"XcmOrderV0","MultiLocation":"MultiLocationV0","AssetId":"u128","TAssetBalance":"u128"}`,
	"moonriver": `{"Weight":"u64","CompactAssignments":"CompactAssignmentsLatest","RefCount":"u32","RoundInfo":{"type_mapping":[["current","RoundIndex"],["first","BlockNumber"],["length","u32"]],"type":"struct"},"Candidate":{"type_mapping":[["id","AccountId"],["fee","Perbill"],["bond","Balance"],["nominators","Vec<Bond>"],["total","Balance"],["state","CollatorStatus"]],"type":"struct"},"RewardInfo":{"type_mapping":[["total_reward","Balance"],["claimed_reward","Balance"]],"type":"struct"},"TxPoolResultStatus":{"type_mapping":[["pending","U256"],["queued","U256"]],"type":"struct"},"CollatorStatus":{"type_mapping":[["Active","NULL"],["Idle","Null"],["Leaving","RoundIndex"]],"type":"enum"},"PoolTransaction":{"type_mapping":[["hash","H256"],["nonce","U256"],["block_hash","Option<H256>"],["block_number","Option<U256>"],["from","H160"],["to","Option<H160>"],["value","U256"],["gas_price","U256"],["gas","U256"],["input","Bytes"]],"type":"struct"},"AccountInfo":"AccountInfoWithTripleRefCount","Collator2":{"type_mapping":[["id","AccountId"],["bond","Balance"],["nominators","Vec<AccountId>"],["top_nominators","Vec<Bond>"],["bottom_nominators","Vec<Bond>"],["total_counted","Balance"],["total_backing","Balance"],["state","CollatorStatus"]],"type":"struct"},"ExtrinsicSignature":"EthereumSignature","NominatorAdded":{"type":"enum","type_mapping":[["AddedToTop","Balance"],["AddedToBottom","Null"]]},"RegistrationInfo":{"type_mapping":[["account","AccountId"],["deposit","Balance"]],"type":"struct"},"Collator":{"type_mapping":[["id","AccountId"],["bond","Balance"],["nominators","Vec<Bond>"],["total","Balance"],["state","CollatorStatus"]],"type":"struct"},"CollatorSnapshot":{"type_mapping":[["bond","Balance"],["nominators","Vec<Bond>"],["total","Balance"]],"type":"struct"},"Address":"AccountId","SystemInherentData":{"type_mapping":[["validation_data","PersistedValidationData"],["relay_chain_state","StorageProof"],["downward_messages","Vec<InboundDownwardMessage>"],["horizontal_messages","BTreeMap<ParaId, Vec<InboundHrmpMessage>>"]],"type":"struct"},"OrderedSet":"Vec<Bond>","AccountId":"EthereumAccountId","Account":{"type_mapping":[["nonce","U256"],["balance","u128"]],"type":"struct"},"RelayChainAccountId":"AccountId32","LookupSource":"AccountId","InflationInfo":{"type_mapping":[["expect","RangeBalance"],["annual","RangePerbill"],["round","RangePerbill"]],"type":"struct"},"AccountId32":"H256","Summary":"Bytes","Range":"RangeBalance","TxPoolResultInspect":{"type_mapping":[["pending","HashMap<H160, HashMap<U256, Summary>>"],["queued","HashMap<H160, HashMap<U256, Summary>>"]],"type":"struct"},"RangeBalance":{"type_mapping":[["min","Balance"],["ideal","Balance"],["max","Balance"]],"type":"struct"},"RoundIndex":"u32","ParachainBondConfig":{"type_mapping":[["account","AccountId"],["percent","Percent"]],"type":"struct"},"Nominator":{"type_mapping":[["nominations","Vec<Bond>"],["total","Balance"]],"type":"struct"},"Balance":"u128","Bond":{"type_mapping":[["owner","AccountId"],["amount","Balance"]],"type":"struct"},"RangePerbill":{"type_mapping":[["min","Perbill"],["ideal","Perbill"],["max","Perbill"]],"type":"struct"},"AuthorId":"AccountId32","TxPoolResultContent":{"type_mapping":[["pending","HashMap<H160, HashMap<U256, PoolTransaction>>"],["queued","HashMap<H160, HashMap<U256, PoolTransaction>>"]],"type":"struct"}}`,
	"moonbeam":  `{"Weight":"u64","CompactAssignments":"CompactAssignmentsLatest","RefCount":"u32","Box<<T as Config>::Call>":"Call","DispatchResult":{"type":"enum","type_mapping":[["Ok","Null"],["Error","DispatchError"]]},"TransactionRecoveryId":"U64","TransactionSignature":{"type":"struct","type_mapping":[["v","TransactionRecoveryId"],["r","H256"],["s","H256"]]},"AccountId":"EthereumAccountId","Address":"AccountId","Balance":"u128","LookupSource":"AccountId","Account":{"type":"struct","type_mapping":[["nonce","U256"],["balance","u128"]]},"RoundIndex":"u32","Candidate":{"type":"struct","type_mapping":[["id","AccountId"],["fee","Perbill"],["bond","Balance"],["nominators","Vec<Bond>"],["total","Balance"],["state","ValidatorStatus"]]},"Bond":{"type":"struct","type_mapping":[["owner","AccountId"],["amount","Balance"]]},"ValidatorStatus":{"type":"enum","type_mapping":[["Active","NULL"],["Idle","NULL"],["Leaving","RoundIndex"]]}}`,
	"westend":   `{"Address":"AccountId","BlockNumber":"u32","LeasePeriod":"BlockNumber","Keys":"SessionKeysPolkadot","Weight":"u32","Weight#3-?":"u64","DispatchInfo":{"type":"struct","type_mapping":[["weight","Weight"],["class","DispatchClass"],["paysFee","Pays"]]},"DispatchResult":{"type":"enum","type_mapping":[["Ok","Null"],["Error","DispatchError"]]},"ProxyType":{"type":"enum","value_list":["Any","NonTransfer","Staking","SudoBalances","IdentityJudgement","CancelProxy"]},"CompactAssignments#43-?":"CompactAssignmentsLatest","RefCount#45-?":"u32","Box<<T as Config>::Call>":"Call","AccountInfo#48-49":"AccountInfoWithProviders","Address#48-?":"MultiAddress","LookupSource#48-?":"MultiAddress","ValidatorPrefs#48-?":"ValidatorPrefsWithBlocked","Keys#48-?":{"type":"struct","type_mapping":[["grandpa","AccountId"],["babe","AccountId"],["im_online","AccountId"],["para_validator","AccountId"],["para_assignment","AccountId"],["authority_discovery","AccountId"]]},"AccountInfo#50-?":"AccountInfoWithTripleRefCount","AssetInstance":"AssetInstanceV0","MultiAsset":"MultiAssetV0","Xcm":"XcmV0","XcmOrder":"XcmOrderV0","MultiLocation":"MultiLocationV0"}`,
	"kusama":    `{"Keys":"SessionKeysPolkadot","ValidatorPrefs":{"type":"struct","type_mapping":[["Commission","Compact<Balance>"]]},"Timepoint":{"type":"struct","type_mapping":[["height","BlockNumber"],["index","u32"]]},"Multisig":{"type":"struct","type_mapping":[["when","Timepoint"],["deposit","Balance"],["depositor","AccountId"],["approvals","Vec<AccountId>"]]},"BalanceLock<Balance>":{"type":"struct","type_mapping":[["id","LockIdentifier"],["amount","Balance"],["reasons","Reasons"]]},"ReferendumInfo<BlockNumber, Hash>":{"type":"enum","type_mapping":[["Ongoing","ReferendumStatus"],["Finished","ReferendumInfoFinished"]]},"DispatchResult":{"type":"enum","type_mapping":[["Ok","Null"],["Error","DispatchError"]]},"Heartbeat":{"type":"struct","type_mapping":[["blockNumber","BlockNumber"],["networkState","OpaqueNetworkState"],["sessionIndex","SessionIndex"],["authorityIndex","AuthIndex"]]},"Weight#1058-?":"u64","Heartbeat#1062-?":{"type":"struct","type_mapping":[["blockNumber","BlockNumber"],["networkState","OpaqueNetworkState"],["sessionIndex","SessionIndex"],["authorityIndex","AuthIndex"],["validatorsLen","u32"]]},"ReferendumInfo<BlockNumber, Hash, BalanceOf>":{"type":"enum","type_mapping":[["Ongoing","ReferendumStatus"],["Finished","ReferendumInfoFinished"]]},"DispatchInfo#1019-1061":"DispatchInfo258","DispatchInfo#1062-?":{"type":"struct","type_mapping":[["weight","Weight"],["class","DispatchClass"],["paysFee","Pays"]]},"ReferendumInfo#1019-1054":{"type":"struct","type_mapping":[["end","BlockNumber"],["proposal","Proposal"],["threshold","VoteThreshold"],["delay","BlockNumber"]]},"DispatchError#1019-1031":{"type":"struct","type_mapping":[["module","Option<u8>"],["error","u8"]]},"ProxyType":{"type":"enum","value_list":["Any","NonTransfer","Governance","Staking","IdentityJudgement","CancelProxy","Auction"]},"Address#1050-2027":"AccountId","Box<Proposal>":"BoxProposal","CompactAssignments#2023-9000":"CompactAssignmentsLatest","RefCount":"u32","Box<<T as Config>::Call>":"Call","Box<<T as Config<I>>::Proposal>":"Proposal","AccountInfo":"AccountInfoWithTripleRefCount","Address#2028-?":"MultiAddress","LookupSource#2028-?":"MultiAddress","Keys#2028-2029":{"type":"struct","type_mapping":[["grandpa","AccountId"],["babe","AccountId"],["im_online","AccountId"],["para_validator","AccountId"],["para_assignment","AccountId"],["authority_discovery","AccountId"]]},"ValidatorPrefs#2028-?":"ValidatorPrefsWithBlocked","Keys#2030-?":"SessionKeys6","CompactAssignments#9010-?":"CompactAssignmentsWith24","AssetInstance#9010-9090":"AssetInstanceV0","MultiAsset#9010-9090":"MultiAssetV0","Xcm#9010-9090":"XcmV0","XcmOrder#9010-9090":"XcmOrderV0","MultiLocation#9010-9090":"MultiLocationV0","AssetInstance#9100-9100":"AssetInstanceV1","MultiAsset#9100-9100":"MultiAssetV1","Xcm#9100-9100":"XcmV1","XcmOrder#9100-9100":"XcmOrderV1","MultiLocation#9100-9100":"MultiLocationV1"}`,
	"polkadot":  `{"Address":"AccountId","BlockNumber":"U32","LeasePeriod":"BlockNumber","Weight":"u64","Keys":"SessionKeysPolkadot","DispatchInfo":{"type":"struct","type_mapping":[["weight","Weight"],["class","DispatchClass"],["paysFee","Pays"]]},"DispatchResult":{"type":"enum","type_mapping":[["Ok","Null"],["Error","DispatchError"]]},"Timepoint":{"type":"struct","type_mapping":[["height","BlockNumber"],["index","u32"]]},"Multisig":{"type":"struct","type_mapping":[["when","Timepoint"],["deposit","Balance"],["depositor","AccountId"],["approvals","Vec<AccountId>"]]},"BalanceLock<Balance, BlockNumber>":{"type":"struct","type_mapping":[["id","LockIdentifier"],["amount","Balance"],["reasons","Reasons"]]},"ProxyType":{"type":"enum","value_list":["Any","NonTransfer","Governance","Staking","DeprecatedSudoBalances","IdentityJudgement","CancelProxy"]},"ReferendumInfo":{"type":"enum","type_mapping":[["Ongoing","ReferendumStatus"],["Finished","ReferendumInfoFinished"]]},"CompactAssignments#23-?":"CompactAssignmentsLatest","RefCount":"u32","Box<<T as Config>::Call>":"Call","Box<<T as Config<I>>::Proposal>":"Proposal","AccountInfo":"AccountInfoWithProviders","Address#28-?":"MultiAddress","LookupSource#28-?":"MultiAddress","Keys#28-29":{"type":"struct","type_mapping":[["grandpa","AccountId"],["babe","AccountId"],["im_online","AccountId"],["para_validator","AccountId"],["para_assignment","AccountId"],["authority_discovery","AccountId"]]},"ValidatorPrefs#28-?":"ValidatorPrefsWithBlocked","Keys#30-?":"SessionKeys6","AccountInfo#30-?":"AccountInfoWithTripleRefCount","AssetInstance":"AssetInstanceV0","MultiAsset":"MultiAssetV0","Xcm":"XcmV0","XcmOrder":"XcmOrderV0","MultiLocation":"MultiLocationV0"}`,
}
