// SPDX-License-Identifier: MIT
// File: @openzeppelin/contracts/utils/Context.sol
// OpenZeppelin Contracts (utils/Context.sol)

pragma solidity ^0.8.18;

/*
* @dev provides information about the current execution context, including the
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

pragma solidity ^0.8.18;

/*
* @dev Contract module which provides a basic access control mechanism, where
* there is an account (an owner) that can be granted exclusive access to
* specific functions.
*
* By default, the owner account will be the one that deploys the contract. This
* can later be changed with {transferOwnership}.
*
* This module is used through inheritance. It will make available the modifier
* `onlyOwner`, which can be applied to your functions to restrict their use to
* the owner.
*/





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
