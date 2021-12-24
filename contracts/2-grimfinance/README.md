Source: https://rekt.news/grim-finance-rekt/

Charge DeFi lost 1849 $CHARGE to the same attack vector just hours before…


The attack exploited a depositFor() function that hadn’t been protected against reentrancy.

1) Grab a Flashloan for XXX & YYY tokens (WBTC-FTM e.g.)

2) Add liquidity on SpiritSwap

3) Mint SPIRIT-LPs

4) call depositFor() in GrimBoostVault with token==ATTACKER, user==ATTACKER

5) Leverage token.safeTransferFrom for re-entrancy

6) goto (4)

7) In the last step on re-entrancy call depositFor() with token==SPIRIT-LP, user==ATTACKER

8) Amount of minted GB-XXX-YYY tokens is increased in every level of re-entrancy

9) Attacker ends up holding huge amount of GB-XXX-YYY tokens

10) Withdraw GB tokens and get more SPIRIT-LP tokens back

11) Remove liquidity and get more XXX and YYY tokens

12) Repay Flashloan

Attacker’s address: 0xdefc385d7038f391eb0063c2f7c238cfb55b206c


Here is a PoC of the reentrancy