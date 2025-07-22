# justfile

build:
    forge build

test:
    forge test

coverage:
    forge coverage

clean:
    forge clean

deploy:
    forge create Counter --rpc-url $RPC_URL --private-key $PRIVATE_KEY

anvil:
    anvil
