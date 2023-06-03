// SPDX-License-Identifier: MIT
// File: @openzeppelin/contracts/utils/Context.sol
// OpenZeppelin Contracts (utils/Context.sol)

pragma solidity ^0.8.20;

/*
* @dev Provides information about the current execution context, including the
* sender of the transaction and its data. While these are generally available
* via msg.sender and msg.data, they should not be accessed in such a direct
* manner, since when dealing with meta-transactions the account sending and
* paying for execution may not be the actual sender (as far as an application
* is concerned). This contract is only required for intermediate, library-like
*contracts.
*/

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// File: @openzeppelin/contracts/access/Ownable.sol
// OpenZeppelin Contracts (access/Ownable.sol)

pragma solidity ^0.8.20;

/*
* @dev Contract module which provides a basic access control mechanism, where
* there is an account (an owner) that can be granted exclusive access to specific functions.
* By default, the owner account will be the one that deploys the contract. This
* can later be changed with {transferOwnership}.
* This module is used through inheritance. It will make available the modifier
* 'onlyOwner', which can be applied to your functions to restrict their use to
* the owner.
*/

abstract contract Ownable is Context {
    address private _owner;
    
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    
    // @dev Initializes the contract setting the deployer as the initial owner.
    constructor() {
        _transferOwnership(_msgSender());
    }
    
    // @dev Returns the address of the current owner.
    function owner() public view virtual returns (address) {
        return _owner;
    }
    
    // @dev Throws if called by any account other than the owner.
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    
    /*
    * @dev Leaves the contract without owner. It will not be possible to call
    * 'onlyOwner' functions anymore. Can only be called by the current owner.
    * NOTE: Renouncing ownership will leave the contract without an owner,
    * thereby removing any functionality that is only available to the owner.
    */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /*
    * @dev Transfers ownership of the contract to a new account (`newOwner`).
    * Can only be called by the current owner.
    */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /*
    * @dev Transfers ownership of the contract to a new account (`newOwner`).
    * Internal function without access restriction.
    */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol
// OpenZeppelin Contracts (token/ERC20/IERC20.sol)

pragma solidity ^0.8.20;

// @dev Interface of the ERC20 standard as defined in the EIP.

interface IERC20 {

    /*
    * @dev Emitted when 'value' tokens are moved from one account ('from') to
    * another ('to').
    * NOTE: 'value' may be zero.
    */
    event transfer(address indexed from, address indexed to, uint256 value);

    /*
    * @dev Emitted when the allowance of a 'spender' for an 'owner' is set by
    * a call to {approve}. 'value' is the new allowance.
    */
    event approval(address indexed owner, address indexed spender, uint256 value);

    // @dev Returns the amount of tokens in existence.
    function totalSupply() external view returns (uint256);

    // @dev Returns the amount of tokens owned by 'account'.
    function balanceOf(address account) external view returns (uint256);

    /*
    * @dev Moves 'amount' tokens from the caller's account to 'recipient'.
    * Returns a boolean value indicating whether the operation succeeded.
    * Emits a {Transfer} event.
    */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /*
    * @dev Returns the remaining number of tokens that 'spender' will be
    * allowed to spend on behalf of 'owner' through {transferFrom}. This is zero by default.
    * This value changes when {approve} or {transferFrom} are called.
    */
    function allowance(address owner, address spender) external view returns (uint256);
    
    /*
    * @dev Sets 'amount' as the allowance of 'spender' over the caller's tokens.
    * Returns a boolean value indicating whether the operation succeeded.
    * IMPORTANT: Beware that changing an allowance with this method brings the risk
    * that someone may use both the old and the new allowance by unfortunate
    * transaction ordering. One possible solution to mitigate this race
    * condition is to first reduce the spender's allowance to 0 and set the
    * desired value afterwards:
    * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
    * Emits an {Approval} event.
    */
    function approve(address spender, uint256 amount) external returns (bool);

    /*
    * @dev Moves 'amount' tokens from 'sender' to 'recipient' using the
    * allowance mechanism. 'amount' is then deducted from the caller's
    * allowance.
    * Returns a boolean value indicating whether the operation succeeded.
    * Emits a {Transfer} event.
    */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

// File: @openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol
// OpenZeppelin Contracts (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.20;

// @dev Interface for the optional metadata functions from the ERC20 standard.

interface IERC20Metadata is IERC20 {
    
    // @dev Returns the name of the token.
    function name() external view returns (string memory);

    // @dev Returns the symbol of the token.
    function symbol() external view returns (string memory);

    // @dev Returns the decimals places of the token.
    function decimals() external view returns (uint8);
}

// File: @openzeppelin/contracts/token/ERC20/ERC20.sol
// OpenZeppelin Contracts (token/ERC20/ERC20.sol)

pragma solidity ^0.8.20;

/*
* @dev Implementation of the {IERC20} interface.
* This implementation is agnostic to the way tokens are created. This means
* that a supply mechanism has to be added in a derived contract using {_mint}.
* For a generic mechanism see {ERC20PresetMinterPauser}.
* We have followed general OpenZeppelin Contracts guidelines: functions revert
* instead returning 'false' on failure. This behavior is nonetheless
* conventional and does not conflict with the expectations of ERC20 applications.
* Additionally, an {Approval} event is emitted on calls to {transferFrom}.
* This allows applications to reconstruct the allowance for all accounts just
* by listening to said events. Other implementations of the EIP may not emit
* these events, as it isn't required by the specification.
* Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
* functions have been added to mitigate the well-known issues around setting
* allowances. See {IERC20-approve}.
*/

contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;

    /*
    * @dev Sets the values for {name} and {symbol}.
    * The default value of {decimals} is 18. To select a different value for
    * {decimals} you should overload it.
    * All two of these values are immutable: they can only be set once during
    * construction.
    */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    // @dev Returns the name of the token.
        function name() public view virtual override returns (string memory) {
        return _name;
    }

    // @dev Returns the symbol of the token, usually a shorter version of the name.
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /*
    * @dev Returns the number of decimals used to get its user representation.
    * For example, if `decimals` equals `2`, a balance of `505` tokens should
    * be displayed to a user as `5.05` (`505 / 10 ** 2`).
    * Tokens usually opt for a value of 18, imitating the relationship between
    * Ether and Wei. This is the value {ERC20} uses, unless this function is overriden.
    * NOTE: This information is only used for _display_ purposes: it in
    * no way affects any of the arithmetic of the contract, including
    * {IERC20-balanceOf} and {IERC20-transfer}.
    */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    // @dev See {IERC20-totalSupply}.
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    // @dev See {IERC20-balanceOf}.
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }














import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

interface INonfungiblePositionManager {
    struct MintParams {
        address token0;
        address token1;
        uint24 fee;
        int24 tickLower;
        int24 tickUpper;
        uint256 amount0Desired;
        uint256 amount1Desired;
        uint256 amount0Min;
        uint256 amount1Min;
        address recipient;
        uint256 deadline;
    }
    function mint(MintParams calldata params) external payable returns (
        uint256 tokenId,
        uint128 liquidity,
        uint256 amount0,
        uint256 amount1
    );
    function createAndInitializePoolIfNecessary(
        address token0,
        address token1,
        uint24 fee,
        uint160 sqrtPriceX96
    ) external payable returns (address pool);
}

contract Meme is ERC20 {
    INonfungiblePositionManager posMan = INonfungiblePositionManager(0xC36442b4a4522E871399CD717aBDD847Ab11FE88);
    address constant weth = 0x9c3C9283D3e44854697Cd22D3Faa240Cfb032889; // polygon mumbai testnet
    //address constant weth = 0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270; // Polygon wMatic
    uint supply = 1_000_000 * 10 ** decimals();
    uint24 constant fee = 500;
    uint160 constant sqrtPriceX96 = 79228162514264337593543950336; // ~ 1:1
    int24 minTick;
    int24 maxTick;
    address public pool;
    address token0;
    address token1;
    uint amount0Desired;
    uint amount1Desired;
    
    constructor() ERC20("Meme Token", "MEME") {
        _mint(address(this), supply);
        fixOrdering();
        pool = posMan.createAndInitializePoolIfNecessary(token0, token1, fee, sqrtPriceX96);
    }

    function addLiquidity() public {
        IERC20(address(this)).approve(address(posMan), supply);
        posMan.mint(INonfungiblePositionManager.MintParams({
            token0: token0,
            token1: token1,
            fee: fee,
            tickLower: minTick,
            tickUpper: maxTick,
            amount0Desired: amount0Desired,
            amount1Desired: amount1Desired,
            amount0Min: 0,
            amount1Min: 0,
            recipient: address(this),
            deadline: block.timestamp + 1200
        }));
    }

    function fixOrdering() private {
        if (address(this) < weth) {
            token0 = address(this);
            token1 = weth;
            amount0Desired = supply;
            amount1Desired = 0;
            minTick = 0;
            maxTick = 887270;
        } else {
            token0 = weth;
            token1 = address(this);
            amount0Desired = 0;
            amount1Desired = supply;
            minTick = -887270;
            maxTick = 0;
        }
    }

}
