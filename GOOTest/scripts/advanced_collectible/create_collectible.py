
from brownie import AdvancedCollectible, accounts, config
from scripts.helpful_scripts import get_breed
import time

STATIC_SEED = 123

def main():
    dev = accounts.add(config['wallets']['from_key'])
    advanced_collectible = AdvancedCollectible[len(AdvancedCollectible) - 1]
    transaction = advanced_collectible.createCollectible(STATIC_SEED, "None", {"from": dev})
    transaction.wait(1)
    time.sleep(51)
    requestId = transaction.events['requestCollectible']['requestId']
    token_id = advanced_collectible.requestIdToTokenId(requestId)
    breed = get_breed(advanced_collectible.tokenIdToBreed(token_id))
    print('Dog breed of tokenId {} is {}'.format(token_id, breed))