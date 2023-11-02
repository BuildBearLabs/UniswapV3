pragma solidity ^0.8.0;

import "./IUniswapV3Factory.sol";
import "./INonfungiblePositionManager.sol";
import "./IUniswapV3Pool.sol";
import "./TransferHelper.sol";


contract UniswapPool {

    uint256 public tokenId;
    // 1% fee
    uint24 public constant fee = 10000;

    address[] public Createdpools;
    address public pool;
    // initial price used to initialize pool is project token0 / token1
    uint160 public constant initialPrice = 1;
    IUniswapV3Factory constant factory = IUniswapV3Factory(0x1F98431c8aD98523631AE4a59f267346ea31F984);
    INonfungiblePositionManager constant positionManager = INonfungiblePositionManager(0xC36442b4a4522E871399CD717aBDD847Ab11FE88);

    function CreatePool(address token1,address token2)public returns(address){
        pool = factory.createPool(token1, token2, fee);
        Createdpools.push(pool);
        // initialize pool
        uint160 sqrtPriceX96 = (sqrt(initialPrice) * 2)**96;
        IUniswapV3Pool(pool).initialize(sqrtPriceX96);
        return pool;
    }

    /**
     * @notice Gets pool address
     */
    function getPools() public view returns (address[] memory) {
        return Createdpools;
    }

    /**
     * @notice Gets pool liquidity
     */
    function getLiquidity(address pool_address) public view returns (uint128) {
        return IUniswapV3Pool(pool_address).liquidity();
    }

    /**
     * @notice Gets pool price as token 0 / token 1 i.e defines how many token0 you get per token 1
     */
    function getPrice(address pool_address)
        external
        view
        returns (uint256 price)
    {
        (uint160 sqrtPriceX96,,,,,,) =  IUniswapV3Pool(pool_address).slot0();
        return uint(sqrtPriceX96) * (uint(sqrtPriceX96)) * (1e18) >> (96 * 2);
    }

    /**
     * @notice Returns Token 0 Address
     */
    function getToken0(address pool_address) external view returns (address) {
        return IUniswapV3Pool(pool_address).token0();
    }

    /**
     * @notice Returns Token 1 Address
     */
    function getToken1(address pool_address) external view returns (address) {
        return IUniswapV3Pool(pool_address).token1();
    }



    /**
     * @notice Gets sq root of a number
     * @param x no to get the sq root of
     */
    function sqrt(uint160 x) internal pure returns (uint160 y) {
        uint160 z = (x + 1) / 2;
        y = x;
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
    }
    function initializePool(address pooladdress, uint256 amount_token0, uint256 amount_token1)external {
        address _token0=IUniswapV3Pool(pooladdress).token0();
        address _token1=IUniswapV3Pool(pooladdress).token1();
        TransferHelper.safeTransferFrom(_token0, msg.sender, address(this),amount_token0 );
        TransferHelper.safeTransferFrom(_token1, msg.sender, address(this),amount_token1 );
        TransferHelper.safeApprove(_token0, address(positionManager),  amount_token0); 
        TransferHelper.safeApprove(_token1, address(positionManager),  amount_token1); 
            INonfungiblePositionManager.MintParams memory params =
            INonfungiblePositionManager.MintParams({
                    token0: IUniswapV3Pool(pooladdress).token0(),
                    token1: IUniswapV3Pool(pooladdress).token1(),
                    fee: fee,
                    tickLower: -887200,
                    tickUpper: 887200,
                    amount0Desired: amount_token0,
                    amount1Desired: amount_token1,
                    amount0Min: 0,
                    amount1Min: 0,
                    recipient: address(this),
                    deadline: block.timestamp + 1000
            });
            (uint mintedId, , , ) = positionManager.mint(params);
            tokenId = mintedId;
    }

    function increase_liquidity(address pooladdress, uint256 amount_token0, uint256 amount_token1 ) external payable {
    
    address _token0=IUniswapV3Pool(pooladdress).token0();
        address _token1=IUniswapV3Pool(pooladdress).token1();
        TransferHelper.safeTransferFrom(_token0, msg.sender, address(this),amount_token0 );
        TransferHelper.safeTransferFrom(_token1, msg.sender, address(this),amount_token1 );
        TransferHelper.safeApprove(_token0, address(positionManager),  amount_token0); 
        TransferHelper.safeApprove(_token1, address(positionManager),  amount_token1); 
            INonfungiblePositionManager.IncreaseLiquidityParams memory params =
            INonfungiblePositionManager.IncreaseLiquidityParams({
                    tokenId: tokenId,
                    amount0Desired: amount_token0,
                    amount1Desired: amount_token1,
                    amount0Min: 0,
                    amount1Min: 0,
                    deadline: block.timestamp + 1000
            });
            positionManager.increaseLiquidity(params);
    }

}