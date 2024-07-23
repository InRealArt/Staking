.PHONY: deploy

# Définir les variables pour les adresses des tokens et les paramètres de déploiement
# Remplacez par l'adresse du token de staking
STAKING_TOKEN_ADDRESS=  
# Remplacez par l'adresse du token de reward (idem staking ou pas)
REWARD_TOKEN_ADDRESS=  
# Remplacez par l'adresse du REWARDER
REWARDER=0x6f74b9c9C65AB3d0C94d0b2F223874d0e874Aa11

deployIraToken:
	@echo "Deploying the contract..."
	forge script script/DeployIraToken.s.sol:DeployIraToken --broadcast --rpc-url $(RPC_URL) --private-key $(PRIVATE_KEY)

deployIraStaking:
    @echo "Deploying the contract..."
    forge script script/DeployIraStaking.s.sol:DeployIraStaking --broadcast --rpc-url $(RPC_URL) --private-key $(PRIVATE_KEY) --constructor-args $(STAKING_TOKEN_ADDRESS) $(REWARD_TOKEN_ADDRESS) $(REWARDER)