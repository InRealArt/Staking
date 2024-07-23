## Staking IRA rules

### Rule 1 : Supply dedicated to rewards

12% of the total supply of IRA Token will be dedicated to staking


### Rule 2 : Reward rates

- **Rate 1** : For a duration lock of 3 months, the reward rate will be 6%
- **Rate 2** : For a duration lock of 6 months, the reward rate will be 9%
- **Rate 3** : For a duration lock of 12 months, the reward rate will be 12%


### Rule 3 

The rates above can be dynamically modified to anticipate lack or excess liquidity of reward supply.
Moreover, we would like to modify these rates for staker that interacts with our DAO.
<br>


## Deployment 

### Deploy IRA Token 


Execute the command : 

```sh
make deployIraToken
```


### Deploy IRA Staking smart contract

Execute the command : 

```sh
make deployIraStaking
```

## TODOS

1) Use ERC1363 instead of ERC20 for IRA token
2) Use correctly Pausable in the staking SC