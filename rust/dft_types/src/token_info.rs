use super::TokenHolder;
use candid::{CandidType, Deserialize, Nat, Principal};

#[derive(CandidType, Debug, Clone, Deserialize)]
pub struct TokenInfo {
    pub owner: Principal,
    pub holders: Nat,
    pub allowance_size: Nat,
    pub fee_to: TokenHolder,
    pub tx_count: Nat,
    pub cycles: u64,
    pub storages: Vec<Principal>,
}
