SSC_HOME := $(shell mktemp -d)

test-gentx:
	rm -rf $(SSC_HOME)
	sscd init test --chain-id ssc-testnet-3 --home $(SSC_HOME)

	cp config/genesis.json $(SSC_HOME)/config/genesis.json
	cp -r gentx $(SSC_HOME)/config/gentx

	@./check-gentx.sh $(SSC_HOME)/config/gentx/*.json

	sscd genesis collect-gentxs --home $(SSC_HOME)
	sscd genesis validate-genesis --home $(SSC_HOME)
	sscd start --home $(SSC_HOME)