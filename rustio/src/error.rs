use reqwest;
use std::io;

#[derive(Fail, Debug)]
pub enum Error {
    #[fail(display = "Reqwest error: {}", _0)]
    RequestError(#[cause] reqwest::Error),

    #[fail(display = "Input/Output error: {}", _0)]
    IoError(#[cause] io::Error),

    #[fail(display = "Unexpected server response: {}", _0)]
    UnexpectedResponse(reqwest::StatusCode),

    #[fail(display = "url error: {}", _0)]
    UrlError(reqwest::UrlError),

     #[fail(display = "Parse error")]
    ParseError,
}

impl From<reqwest::Error> for Error {
    fn from(err: reqwest::Error) -> Self {
        Error::RequestError(err)
    }
}

impl From<io::Error> for Error {
    fn from(err: io::Error) -> Self {
        Error::IoError(err)
    }
}

impl From<reqwest::UrlError> for Error {
    fn from(err: reqwest::UrlError) -> Self {
        Error::UrlError(err)
    }
}
