// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.8.0;
pragma experimental ABIEncoderV2;

import "../Libraries/TypesLib.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/IERC1155Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/IERC1155ReceiverUpgradeable.sol";

/**
   @title Interface of BSHCore contract
   @dev This contract is used to handle coin transferring service
   Note: The coin of following interface can be:
   Native Coin : The native coin of this chain
   Wrapped Native Coin : A tokenized ERC1155 version of another native coin like ICX
*/
interface IBSHCore is IERC1155Upgradeable, IERC1155ReceiverUpgradeable {
    /**
        @notice update BSH Periphery address.
        @dev Caller must be an Owner of this contract
        _bshPeriphery Must be different with the existing one.
        @param _bshPeriphery    BSHPeriphery contract address.
    */
    function updateBSHPeriphery(address _bshPeriphery) external;

    /**
        @notice update base uri.
        @dev Caller must be an Owner of this contract
        the uri must be initilized in construction.
        @param _newURI    new uri
    */
    function updateUri(string calldata _newURI) external;

    /**
        @notice set fee ratio.
        @dev Caller must be an Owner of this contract
        The transfer fee is calculated by feeNumerator/FEE_DEMONINATOR. 
        The feeNumetator should be less than FEE_DEMONINATOR
        _feeNumerator is set to `10` in construction by default, which means the default fee ratio is 0.1%.
        @param _feeNumerator    the fee numerator
    */
    function setFeeRatio(uint256 _feeNumerator) external;

    /**
        @notice Registers a wrapped coin and id number of a supporting coin.
        @dev Caller must be an Owner of this contract
        _name Must be different with the native coin name.
        @dev '_id' of a wrapped coin is generated by using keccak256
          '_id' = 0 is fixed to assign to native coin
        @param _name    Coin name. 
    */
    function register(string calldata _name) external;

    /**
       @notice Return all supported coins names
       @dev 
       @return _names   An array of strings.
    */
    function coinNames() external view returns (string[] memory _names);

    /**
       @notice  Return an _id number of Coin whose name is the same with given _coinName.
       @dev     Return nullempty if not found.
       @return  _coinId     An ID number of _coinName.
    */
    function coinId(string calldata _coinName)
        external
        view
        returns (uint256 _coinId);

    /**
       @notice  Check Validity of a _coinName
       @dev     Call by BSHPeriphery contract to validate a requested _coinName
       @return  _valid     true of false
    */
    function isValidCoin(string calldata _coinName)
        external
        view
        returns (bool _valid);

    /**
        @notice Return a usable/locked/refundable balance of an account based on coinName.
        @return _usableBalance the balance that users are holding.
        @return _lockedBalance when users transfer the coin, 
                it will be locked until getting the Service Message Response.
        @return _refundableBalance refundable balance is the balance that will be refunded to users.
    */
    function getBalanceOf(address _owner, string memory _coinName)
        external
        view
        returns (
            uint256 _usableBalance,
            uint256 _lockedBalance,
            uint256 _refundableBalance
        );

    /**
        @notice Return a list Balance of an account.
        @dev The order of request's coinNames must be the same with the order of return balance
        Return 0 if not found.
        @return _usableBalances         An array of Usable Balances
        @return _lockedBalances         An array of Locked Balances
        @return _refundableBalances     An array of Refundable Balances
    */
    function getBalanceOfBatch(address _owner, string[] calldata _coinNames)
        external
        view
        returns (
            uint256[] memory _usableBalances,
            uint256[] memory _lockedBalances,
            uint256[] memory _refundableBalances
        );

    /**
        @notice Return a list accumulated Fees.
        @dev only return the asset that has Asset's value greater than 0
        @return _accumulatedFees An array of Asset
    */
    function getAccumulatedFees()
        external
        view
        returns (Types.Asset[] memory _accumulatedFees);

    /**
       @notice Allow users to deposit `msg.value` native coin into a BSHCore contract.
       @dev MUST specify msg.value
       @param _to  An address that a user expects to receive an amount of tokens.
    */
    function transfer(string calldata _to) external payable;

    /**
       @notice Allow users to deposit an amount of wrapped native coin `_coinName` from the `msg.sender` address into the BSHCore contract.
       @dev Caller must set to approve that the wrapped tokens can be transferred out of the `msg.sender` account by BSHCore contract.
       It MUST revert if the balance of the holder for token `_coinName` is lower than the `_value` sent.
       @param _coinName    A given name of a wrapped coin 
       @param _value       An amount request to transfer.
       @param _to          Target BTP address.
    */
    function transfer(
        string calldata _coinName,
        uint256 _value,
        string calldata _to
    ) external;

    /**
       @notice Allow users to transfer multiple coins/wrapped coins to another chain
       @dev Caller must set to approve that the wrapped tokens can be transferred out of the `msg.sender` account by BSHCore contract.
       It MUST revert if the balance of the holder for token `_coinName` is lower than the `_value` sent.
       In case of transferring a native coin, it also checks `msg.value` with `_values[i]`
       It MUST revert if `msg.value` is not equal to `_values[i]`
       The number of requested coins MUST be as the same as the number of requested values
       The requested coins and values MUST be matched respectively
       @param _coinNames    A list of requested transferring coins/wrapped coins
       @param _values       A list of requested transferring values respectively with its coin name
       @param _to          Target BTP address.
    */
    function transferBatch(
        string[] memory _coinNames,
        uint256[] memory _values,
        string calldata _to
    ) external payable;

    /**
        @notice Reclaim the token's refundable balance by an owner.
        @dev Caller must be an owner of coin
        The amount to claim must be smaller or equal than refundable balance
        @param _coinName   A given name of coin
        @param _value       An amount of re-claiming tokens
    */
    function reclaim(string calldata _coinName, uint256 _value) external;

    /**
        @notice return coin for the failed transfer.
        @dev Caller must be itself
        @param _to    account
        @param _coinName    coin name    
        @param _value    the minted amount   
    */
    function refund(
        address _to,
        string calldata _coinName,
        uint256 _value
    ) external;

    /**
        @notice mint the wrapped coin.
        @dev Caller must be an BSHPeriphery contract
        Invalid _coinName will have an _id = 0. However, _id = 0 is also dedicated to Native Coin
        Thus, BSHPeriphery will check a validity of a requested _coinName before calling
        for the _coinName indicates with id = 0, it should send the Native Coin (Example: PRA) to user account
        @param _to    the account receive the minted coin
        @param _coinName    coin name
        @param _value    the minted amount   
    */
    function mint(
        address _to,
        string calldata _coinName,
        uint256 _value
    ) external;

    /**
        @notice Handle when Fee Gathering request receives an error response
            Usage: Copy back pending state of charged fees back to aggregationFee state variable
        @dev Caller must be an BSHPeriphery contract
        @param _fees    An array of charged fees
    */
    function handleErrorFeeGathering(Types.Asset[] memory _fees) external;

    /**
        @notice Handle a request of Fee Gathering
            Usage: Copy all charged fees to an array
        @dev Caller must be an BSHPeriphery contract
        @return _pendingFA      An array of charged fees
    */
    function gatherFeeRequest()
        external
        returns (Types.Asset[] memory _pendingFA);

    /**
        @notice Handle a response of a requested service
        @dev Caller must be an BSHPeriphery contract
        @param _requester   An address of originator of a requested service
        @param _coinName    A name of requested coin
        @param _value       An amount to receive on a destination chain
        @param _fee         An amount of charged fee
    */
    function handleResponseService(
        address _requester,
        string calldata _coinName,
        uint256 _value,
        uint256 _fee,
        uint256 rspCode
    ) external;
}
