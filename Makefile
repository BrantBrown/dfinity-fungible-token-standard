.PHONY: all
all: build

.PHONY: build
.SILENT: build
build:
	dfx canister --no-wallet create --all
	dfx build

.PHONY: install
.SILENT: install
install: build
	dfx canister --no-wallet  install dft_rs \
	  --argument '(null ,null ,"Deland Token", "DLD", 18:nat8, 100000000000000000000000000:nat, record { lowest = 1 : nat; rate = 0 : nat } , null)'
	dfx canister --no-wallet  install dft_motoko \
	  --argument '(null ,null ,"Deland Token", "DLD", 18:nat8, 100000000000000000000000000:nat, record { lowest = 1 : nat; rate = 0 : nat }, null)'

.PHONY: upgrade
.SILENT: upgrade
upgrade: build
	dfx canister --no-wallet  install dft_rs \
	  --argument '(null ,null ,"Deland Token", "DLD", 18:nat8, 100000000000000000000000000:nat, record { lowest = 1 : nat; rate = 0 : nat }, null)' \
	  --mode reinstall
	dfx canister --no-wallet  install dft_motoko \
	  --argument '(null ,null ,"Deland Token", "DLD", 18:nat8, 100000000000000000000000000:nat, record { lowest = 1 : nat; rate = 0 : nat }, null)' \
		--mode reinstall
 
define test_token_impl
	@echo "calling $(0), will test $(1)"
	$(eval dft_id := $(shell dfx canister id $(1)))
	$(eval owner_id := $(shell dfx identity get-principal))
	dfx canister call $(1)  name | grep 'Deland Token' && echo 'PASS name check'
	dfx canister call $(1)  symbol | grep 'DLD' && echo 'PASS symbol check'
	dfx canister call $(1)  decimals | grep '(18 : nat8)' && echo 'PASS decimals check'
	dfx canister call $(1)  totalSupply \
	| grep '(100_000_000_000_000_000_000_000_000 : nat)' && echo 'PASS totalSupply check'
	dfx canister call $(1)  fee | grep '0 : nat' && echo 'PASS fee check'
	dfx canister call $(1)  meta | grep 'Deland Token' && echo 'PASS meta check'

	dfx canister call $(1) transfer '(null,"rrkah-fqaaa-aaaaa-aaaaq-cai",1000000000000000000:nat,null)' \
	| grep 'Ok' && echo 'PASS transfer check'
	dfx canister call $(1) balanceOf "rrkah-fqaaa-aaaaa-aaaaq-cai" \
	| grep '1_000_000_000_000_000_000' && echo 'PASS balanceOf check'

	dfx canister call $(1) balanceOf "$(owner_id)" \
	| grep '99_999_999_000_000_000_000_000_000' && echo 'PASS balanceOf check'

	dfx canister call $(1) setExtend '(vec {record {k = "OFFICIAL_SITE"; v = "http://test.com" }})' \
	| grep '(true)' && echo 'PASS updateExtend test'
	dfx canister call $(1) extend  \
	| grep 'k = "OFFICIAL_SITE"; v = "http://test.com"' && echo 'PASS extend test'

	dfx canister call $(1) setFee '(record { lowest = 1 : nat; rate = 0 : nat })' \
	| grep '(true)' && echo 'PASS set fee test'
	dfx canister call $(1) fee  \
	| grep '(record { rate = 0 : nat; lowest = 1 : nat })' && echo 'PASS fee check 2'

	dfx canister call $(1) approve '(null,"rrkah-fqaaa-aaaaa-aaaaq-cai",3000000000000000000:nat,null)'
	dfx canister call $(1) allowance '("$(owner_id)","rrkah-fqaaa-aaaaa-aaaaq-cai")' \
	| grep '3_000_000_000_000_000_000' && echo 'PASS allowance check'
	sleep 3
endef

.PHONY: test_rs
.SILENT: test_rs
test_rs: upgrade
	$(call test_token_impl,dft_rs)

.PHONY: test_motoko
.SILENT: test_motoko
test_motoko: upgrade
	$(call test_token_impl,dft_motoko)

.PHONY: clean
.SILENT: clean
clean:
	rm -fr .dfx
