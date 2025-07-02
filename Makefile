test-gentx:
	rm -rf .ssc
	sscd init test --chain-id ssc-testnet-3 --home .ssc

	cp config/genesis.json .ssc/config/genesis.json
	cp -r gentx .ssc/config/gentx

	@./check-gentx.sh .ssc/config/gentx/*.json

	sscd genesis collect-gentxs --home .ssc
	sscd genesis validate-genesis --home .ssc
	sscd start --home .ssc