Source:
https://rekt.news/visor-finance-rekt/

contract
https://etherscan.io/address/0xc9f27a50f82571c1c8423a42970613b8dbda14ef#code

exploited
https://etherscan.io/tx/0x69272d8c84d67d1da2f6425b339192fa472898dce936f24818fda415c1c1ff3f
#Block:13849007


Due to a vulnerable require() check in the vVISR Rewards Contract’s deposit() function, the hacker was able to mint unlimited shares using their own contract.

deposit function
```
if(isContract(from)) {
  require(IVisor(from).owner() == msg.sender); 
  IVisor(from).delegatedTransferERC20(address(visr), address(this), visrDeposit);
}
```