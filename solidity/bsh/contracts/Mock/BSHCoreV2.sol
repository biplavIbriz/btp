// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.8.0;
pragma experimental ABIEncoderV2;
import "../Interfaces/IBSHPeriphery.sol";
import "../Interfaces/IBSHCore.sol";
import "../Libraries/StringsLib.sol";
import "../Libraries/TypesLib.sol";
import "@openzeppelin/contracts-upgradeable/math/SafeMathUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155HolderUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
/**
   @title Interface of BSH Coin transfer service
   @dev This contract use to handle coin transfer service
   Note: The coin of following interface can be:
   Native Coin : The native coin of this chain
   Wrapped Native Coin : A tokenized ERC1155 version of another native coin like ICX
*/
contract BSHCoreV2 is Initializable, IBSHCore, ERC1155Upgradeable, ERC1155HolderUpgradeable, OwnableUpgradeable {
    using SafeMathUpgradeable for uint256;
    using Strings for string;

    modifier onlyBSHPeriphery {
        require(msg.sender == address(bshPeriphery), "Unauthorized");
        _;
    }

    IBSHPeriphery private bshPeriphery;
    mapping(string => uint256) internal aggregationFee;   // storing Aggregation Fee in state mapping variable. MUST set back to 'private' after testing
    mapping(address => mapping(string => Types.Balance)) private balances;
    mapping(string => uint256) private coins; //  a list of all supported coins
    string[] private coinsName; // a string array stores names of supported coins
    Types.Asset[] internal temp;

    uint256 private constant FEE_DENOMINATOR = 10**4;
    uint256 private feeNumerator;
    uint256 private constant RC_OK = 0;
    uint256 private constant RC_ERR = 1;

    //  This is just an example to show how to add more state variable
    mapping(address => mapping(string => uint256)) private stakes;

    function initialize (
        string calldata _uri,
        string calldata _nativeCoinName,
        uint256 _feeNumerator
    ) public initializer {
        __ERC1155_init(_uri);
         __ERC1155Holder_init();
        __Ownable_init();

        coins[_nativeCoinName] = 0;         
        feeNumerator = _feeNumerator;
        coinsName.push(_nativeCoinName);
    }

    //  @notice This is just an example to show how to add more function in upgrading a contract
    function addStake(string calldata _coinName, uint256 _value) external payable {
        if (_coinName.compareTo(coinsName[0])) {
            require(msg.value == _value, "InvalidAmount");
        }else {
            this.safeTransferFrom(msg.sender, address(this), coins[_coinName], _value, "");
        }
        stakes[msg.sender][_coinName] = stakes[msg.sender][_coinName].add(_value);
    }

    //  @notice This is just an example to show how to add more function in upgrading a contract
    function mintMock(address _acc, uint256 _id, uint256 _value) external {
        _mint(_acc, _id, _value, "");
    }

    //  @notice This is just an example to show how to add more function in upgrading a contract
    function burnMock(address _acc, uint256 _id, uint256 _value) external {
        _burn(_acc, _id, _value);
    }

    //  @notice This is just an example to show how to add more function in upgrading a contract
    function setAggregationFee(string calldata _coinName, uint256 _value) external {
        aggregationFee[_coinName] += _value;
    }

    //  @notice This is just an example to show how to add more function in upgrading a contract
    function clearAggregationFee() external {
        for (uint i = 0; i < coinsName.length; i++) {
            delete aggregationFee[coinsName[i]];
        }
    }

    //  @notice This is just an example to show how to add more function in upgrading a contract
    function setRefundableBalance(address _acc, string calldata _coinName, uint256 _value) external {
        balances[_acc][_coinName].refundableBalance += _value;
    }

    /**
        @notice update bsh service address.
        @dev Caller must be an operator of BTP network
        _bshPeriphery Must be different with the existing one.
        @param _bshPeriphery    bsh service address.
    */
    function updateBSHPeriphery(address _bshPeriphery) external override onlyOwner {
        bshPeriphery = IBSHPeriphery(_bshPeriphery);
    }

    /**
        @notice update base uri.
        @dev Caller must be an operator of BTP network
        the uri must be initilized in construction.
        @param _newURI    new uri
    */
    function updateUri(string calldata _newURI) external override onlyOwner {
       _setURI(_newURI);
    }

    /**
        @notice set fee ratio.
        @dev Caller must be an operator of BTP network
        The transfer fee is calculated by feeNumerator/FEE_DEMONINATOR. 
        The feeNumetator should be less than FEE_DEMONINATOR
        _feeNumerator is set to `10` in construction by default, which means the default fee ratio is 0.1%.
        @param _feeNumerator    the fee numerator
    */
    function setFeeRatio(uint256 _feeNumerator) external override onlyOwner {
        //  Assuming, adding require() to check input _feeNumerator when upgrading a contract
        require(_feeNumerator <= FEE_DENOMINATOR, "InvalidSetting");
        feeNumerator = _feeNumerator;
    }

    /**
        @notice Registers a wrapped coin and id number of a supporting coin.
        @dev Caller must be an Contract Owner
        _name Must be different with the native coin name.
        @dev '_id' of a wrapped coin is generated by using keccak256
          '_id' = 0 is fixed to assign to native coin
        @param _name    Coin name. 
    */
    function register(
        string calldata _name
    ) external override onlyOwner {
        require(coins[_name] == 0, "ExistToken");
        coins[_name] = uint256(keccak256(abi.encodePacked(_name)));
        coinsName.push(_name);
    }

    /**
       @notice Return all supported coins names in other networks by the BSH contract
       @dev 
       @return _names   An array of strings.
    */
    function coinNames() external override view returns (string[] memory _names) {
        return coinsName;
    }

    /**
       @notice  Return an _id number of Coin whose name is the same with given _coinName.
       @dev     Return nullempty if not found.
       @return  _coinId     An ID number of _coinName.
    */
    function coinId(string calldata _coinName) external override view returns (uint256 _coinId) {
        return coins[_coinName];
    }

    /**
       @notice  Check Validity of a _coinName
       @dev     Call by BSHPeriphery contract to validate a requested _coinName
       @return  _valid     true of false
    */
    function isValidCoin(string calldata _coinName) external override view returns (bool _valid) {
        return (coins[_coinName] != 0 || _coinName.compareTo(coinsName[0])); 
    }

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
        override
        returns (uint256 _usableBalance, uint256 _lockedBalance, uint256 _refundableBalance)
    {
        if (_coinName.compareTo(coinsName[0])) {
            return (
                address(_owner).balance,
                balances[_owner][_coinName].lockedBalance,
                balances[_owner][_coinName].refundableBalance
            );
        }
        return (
            this.balanceOf(_owner, coins[_coinName]),
            balances[_owner][_coinName].lockedBalance,
            balances[_owner][_coinName].refundableBalance
        );
    }

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
        override
        returns
    (
        uint256[] memory _usableBalances,
        uint256[] memory _lockedBalances,
        uint256[] memory _refundableBalances
    ){
        _usableBalances = new uint256[](_coinNames.length);
        _lockedBalances = new uint256[](_coinNames.length);
        _refundableBalances = new uint256[](_coinNames.length);
        for (uint256 i = 0; i < _coinNames.length; i++) {
            (_usableBalances[i], _lockedBalances[i], _refundableBalances[i]) =
                this.getBalanceOf(_owner, _coinNames[i]);
        }
        return (_usableBalances, _lockedBalances, _refundableBalances);
    }

    /**
        @notice Return a list accumulated Fees.
        @dev only return the asset that has Asset's value greater than 0
        @return _accumulatedFees An array of Asset
    */
    function getAccumulatedFees()
        external
        view
        override
        returns (Types.Asset[] memory _accumulatedFees)
    {
        _accumulatedFees = new Types.Asset[](coinsName.length);
        for (uint i = 0; i < coinsName.length; i++) {
            _accumulatedFees[i] = (
                Types.Asset(coinsName[i], aggregationFee[coinsName[i]])
            );
        }
        return _accumulatedFees;
    }

    /**
       @notice Allow users to deposit `msg.value` native coin into a BSH contract.
       @dev MUST specify msg.value
       @param _to  An address that a user expects to receive an amount of tokens.
    */
    function transfer(string calldata _to) external override payable {
        //  Aggregation Fee will be charged on BSH Contract
        //  A Fee Ratio is set when BSH contract is created
        //  If charging fee amount is zero, revert()
        //  Otherwise, charge_amt = (_amt * feeNumerator) / FEE_DENOMINATOR
        uint chargeAmt = msg.value.mul(feeNumerator).div(FEE_DENOMINATOR);
        require(chargeAmt > 0, "InvalidAmount");
        lockBalance(msg.sender, coinsName[0], msg.value);
        bshPeriphery.sendServiceMessage(msg.sender, _to, coinsName[0], msg.value.sub(chargeAmt), chargeAmt);
    }

    /**
       @notice Allow users to deposit an amount of wrapped native coin `_coinName` from the `msg.sender` address into the BSH contract.
       @dev Caller must set to approve that the wrapped tokens can be transferred out of the `msg.sender` account by the operator.
       It MUST revert if the balance of the holder for token `_coinName` is lower than the `_value` sent.
       @param _coinName    A given name of a wrapped coin 
       @param _value       An amount request to transfer.
       @param _to          Target BTP address.
    */
    function transfer(
        string calldata _coinName,
        uint256 _value,
        string calldata _to
    ) external override {
        require(
            coins[_coinName] != 0,
            "unregistered_coin"     //  Assuming, change revert() response when upgrading a contract
        );
        uint chargeAmt = _value.mul(feeNumerator).div(FEE_DENOMINATOR);
        require(chargeAmt > 0, "InvalidAmount");
        //  Transfer and Lock Token processes:
        //  BSHCorecontract calls safeTransferFrom() to transfer the Token from Caller's account (msg.sender)
        //  Before that, Caller must approve (setApproveForAll) to accept
        //  token being transfer out by an Operator
        //  If this requirement is failed, a transaction is reverted.
        //  After transferring token, BSHCore contract updates Caller's locked balance
        //  as a record of pending transfer transaction
        //  When a transaction is completed without any error on another chain,
        //  Locked Token amount (bind to an address of caller) will be reset/subtract,
        //  then emit a successful TransferEnd event as a notification
        //  Otherwise, the locked amount will also be updated 
        //  but BSHCore contract will issue a refund to Caller before emitting an error TransferEnd event
        this.safeTransferFrom(msg.sender, address(this), coins[_coinName], _value, "");
        lockBalance(msg.sender, _coinName, _value);
        bshPeriphery.sendServiceMessage(msg.sender, _to, _coinName, _value.sub(chargeAmt), chargeAmt);
    }

    /**
        @notice Reclaim the token's refundable balance by an owner.
        @dev Caller must be an owner of coin
        The amount to claim must be smaller than refundable balance
        @param _coinName   A given name of coin
        @param _value       An amount of re-claiming tokens
    */
    function reclaim (string calldata _coinName, uint256 _value) external override {
        require(
            balances[msg.sender][_coinName].refundableBalance >= _value,
            "Imbalance"
        );

        balances[msg.sender][_coinName].refundableBalance = balances[
            msg.sender
        ][_coinName]
            .refundableBalance
            .sub(_value);

        this.refund(msg.sender, _coinName, _value);
    }
 
    /**
        @notice return coin for the failed transfer.
        @dev Caller must be this contract
        @param _to    account
        @param _coinName    coin name    
        @param _value    the minted amount   
    */
    function refund(address _to, string calldata _coinName, uint256 _value) external override {
        require(msg.sender == address(this), "Unauthorized");
        uint256 _id = coins[_coinName];
        if (_id == 0) {
            payable(_to).transfer(_value);
        } else {
            this.safeTransferFrom(address(this), _to, _id, _value, "");
        }
    }

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
    function mint(address _to, string calldata _coinName, uint256 _value) external override onlyBSHPeriphery {   
        uint256 _id = coins[_coinName];
        if (_id == 0) {
            payable(_to).transfer(_value);
        }else {
            _mint(_to, _id, _value, "");
        }
    }

    /**
        @notice burn the wrapped coin.
        @dev Caller must be an BSHPeriphery contract
        _id = 0 is dedicated to Native Coin (e.g. PARA). It cannot be burnt. Ignore it therein
        @param _coinName    coin name
        @param _value    the minted amount   
    */
    // function burn(string calldata _coinName, uint256 _value) private {
    //     uint256 _id = coins[_coinName];
    //     if (_id != 0) {
    //         _burn(address(this), _id, _value);
    //     }    
    // }

    function handleResponseService(
        address _caller,
        string calldata _coinName,
        uint256 _value,
        uint256 _fee,
        uint256 rspCode
    ) external override onlyBSHPeriphery {
        uint _amount = _value.add(_fee);
        balances[_caller][_coinName].lockedBalance = balances[
            _caller
        ][_coinName]
            .lockedBalance
            .sub(_amount);
        if (rspCode == RC_ERR) {
            try this.refund(_caller, _coinName, _amount) {}
            catch {
                balances[_caller][_coinName].refundableBalance = balances[
                    _caller
                ][_coinName]
                    .refundableBalance
                    .add(_amount);
            }
        } else if (rspCode == RC_OK) {
            uint256 _id = coins[_coinName];
            if (_id != 0) {
                _burn(address(this), _id, _value);
            }    
            aggregationFee[_coinName] = _fee;
        }
    }

    function handleErrorFeeGathering(Types.Asset[] memory _fees) external override onlyBSHPeriphery {
        for (uint i = 0; i < _fees.length; i++) {
            //  Assuming, previous logic implementation is not correct
            //  When upgrading a contract, modify code to fix bug
            aggregationFee[_fees[i].coinName] = aggregationFee[_fees[i].coinName].add(_fees[i].value);
        }
    }

    function gatherFeeRequest() external override onlyBSHPeriphery returns (Types.Asset[] memory _pendingFA) {
        for (uint i = 0; i < coinsName.length; i++) {
            if (aggregationFee[coinsName[i]] != 0) {
                temp.push(
                    Types.Asset(coinsName[i], aggregationFee[coinsName[i]])
                );
                delete aggregationFee[coinsName[i]];
            }
        }
        _pendingFA = temp;
        delete temp;
        return _pendingFA;
    }

    function lockBalance(address _to, string memory _coinName, uint256 _value) private {
        balances[_to][_coinName].lockedBalance = balances[
            _to
        ][_coinName]
            .lockedBalance
            .add(_value);
    }
}
