// SPDX-License-Identifier: MIT

//-------------------------------------------------------------------------------------------------------
pragma solidity ^0.8.20;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

//-------------------------------------------------------------------------------------------------------
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

//-------------------------------------------------------------------------------------------------------
// File: contracts/icaruscoin.sol

contract Icarus is ERC20, ERC20Burnable, Ownable {
    uint256 initialSupply = 149597870700 * 10 ** decimals();
    address public immutable dexWallet = <dex_wallet>
    address public immutable cexWallet = <cex_wallet>
    bool public limited;
    uint256 public maxHoldingAmount;
    uint256 public minHoldingAmount;
    address public uniswapV2Pair;
    mapping(address => bool) public blacklists;

    constructor() ERC20("Icarus", "ICARUS") {
        uint256 creatorSupply = initialSupply / 10;
        uint256 dexSupply = initialSupply * 8 / 10;
        uint256 cexSupply = initialSupply / 10;
        
        _mint(msg.sender, creatorSupply);
        _mint(dexWallet, dexSupply);
        _mint(cexWallet, cexSupply);
    }
    
    function blacklist(address _address, bool _isBlacklisting) external onlyOwner {
        blacklists[_address] = _isBlacklisting;
    }   
    
    function setRule(bool _limited, address _uniswapV2Pair, uint256 _maxHoldingAmount, 
    uint256 _minHoldingAmount) external onlyOwner {
        limited = _limited;
        uniswapV2Pair = _uniswapV2Pair;
        maxHoldingAmount = _maxHoldingAmount;
        minHoldingAmount = _minHoldingAmount;
    }
    
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) override internal virtual {
        require(!blacklists[to] && !blacklists[from], "Blacklisted");

        if (uniswapV2Pair == address(0)) {
            require(from == owner() || to == owner(), "trading not available");
            return;
        }

        if (limited && from == uniswapV2Pair) {
            require(super.balanceOf(to) + amount <= maxHoldingAmount && 
            super.balanceOf(to) + amount >= minHoldingAmount, "Forbidden");
        }
    }
    
    function burn(uint256 amount) external {
        _burn(msg.sender, amount);
    }
    
    function renounceOwnership() external onlyOwner {
        renounceOwn();
    }


}



//-------------------------------------------------------------------------------------------------------


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
