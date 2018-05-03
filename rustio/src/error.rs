extern crate reqwest;
use serde_json::Value as JsonValue;

pub enum Error {
    ReqwestError(reqwest::Error),
    ServerError(JsonValue),
}