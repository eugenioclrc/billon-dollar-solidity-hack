// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// import "./interfaces/IVisor.sol";
interface IVisor {
    function owner() external returns(address);
    function delegatedTransferERC20( address token, address to, uint256 amount) external;
}

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Snapshot.sol";

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract VISR is ERC20 {
    constructor(uint256 amount) ERC20("VISR", "VISR") {
      _mint(msg.sender, amount);
    }
}

contract vVISR is ERC20Snapshot {

    address public owner;
    modifier onlyOwner {
        require(msg.sender == owner, "only owner");
        _;
    }

    constructor(
        string memory name,
        string memory symbol,
        uint8 decimals
    ) ERC20(name, symbol){
      owner = msg.sender;
    }

    function mint(address account, uint256 amount) onlyOwner external {
      _mint(account, amount);
    }

    function burn(address account, uint256 amount) onlyOwner external {
      _burn(account, amount);
    }

    function snapshot() onlyOwner external {
      _snapshot();
    }

    function transferOwnership(address newOwner) external onlyOwner {
      owner = newOwner;
    }


}

// @title Rewards Hypervisor
// @notice fractionalize balance 
contract RewardsHypervisor {
    using SafeERC20 for IERC20;
    
    address public owner;
    IERC20 public visr;
    vVISR public vvisr;

    modifier onlyOwner {
        require(msg.sender == owner, "only owner");
        _;
    }

    constructor(
        address _visr,
        address _vvisr
    ) {
        visr = IERC20(_visr);
        vvisr = vVISR(_vvisr);
        owner = msg.sender;
    }

    // @param visr Amount of VISR transfered from sender to Hypervisor
    // @param to Address to which liquidity tokens are minted
    // @param from Address from which tokens are transferred 
    // @return shares Quantity of liquidity tokens minted as a result of deposit
    function deposit(
        uint256 visrDeposit,
        address payable from,
        address to
    ) external returns (uint256 shares) {
        require(visrDeposit > 0, "deposits must be nonzero");
        require(to != address(0) && to != address(this), "to");
        require(from != address(0) && from != address(this), "from");

        shares = visrDeposit;
        if (vvisr.totalSupply() != 0) {
          uint256 visrBalance = visr.balanceOf(address(this));
          shares = (shares*vvisr.totalSupply()) / visrBalance;
        }

        if(isContract(from)) {
          require(IVisor(from).owner() == msg.sender); 
          IVisor(from).delegatedTransferERC20(address(visr), address(this), visrDeposit);
        }
        else {
          visr.safeTransferFrom(from, address(this), visrDeposit);
        }

        vvisr.mint(to, shares);
    }

    // @param shares Number of rewards shares to redeem for VISR
    // @param to Address to which redeemed pool assets are sent
    // @param from Address from which liquidity tokens are sent
    // @return rewards Amount of visr redeemed by the submitted liquidity tokens
    function withdraw(
        uint256 shares,
        address to,
        address payable from
    ) external returns (uint256 rewards) {
        require(shares > 0, "shares");
        require(to != address(0), "to");
        require(from != address(0), "from");

        rewards = (visr.balanceOf(address(this)) * shares) / vvisr.totalSupply();
        visr.safeTransfer(to, rewards);

        require(from == msg.sender || IVisor(from).owner() == msg.sender, "Sender must own the tokens");
        vvisr.burn(from, shares);
    }

    function snapshot() external onlyOwner {
      vvisr.snapshot();
    }

    function transferOwnership(address newOwner) external onlyOwner {
      owner = newOwner;
    }

    function transferTokenOwnership(address newOwner) external onlyOwner {
      vvisr.transferOwnership(newOwner); 
    }

    function isContract(address _addr) private returns (bool isContract){
				uint32 size;
				assembly {
					size := extcodesize(_addr)
				}
				return (size > 0);
		}

}