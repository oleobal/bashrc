use std::env;
use std::process::ExitCode;

static CHARS_WHITESPACE:&str=" \t\n";
static CHARS_CAPS:&str="QWERTYUIOPASDFGHJKLZXCVBNM";
static CHARS_BREAK:&str=".-_";

#[derive(PartialEq,Debug)]
enum CharType {
    NONE,
    WS,
    BREAK,
    CAP,
    WORD
}

fn get_short_cwd(cwd : &str) -> String {
    let mut folders = cwd.split("/").collect::<Vec<&str>>();
    let last = folders.pop();
    if last.is_none() {return "/".to_string();}
    let z = folders.into_iter().map(|folder| shorten_folder(folder)).collect::<Vec<String>>().join("/") + "/" + last.unwrap();
    return z;
}

fn shorten_folder(folder: &str) -> String {
    let mut words = Vec::<char>::new();
    let mut last = CharType::NONE;
    for c in folder.chars() {
        if CHARS_BREAK.contains(c) {
            if last != CharType::BREAK { words.push(c) }
            last = CharType::BREAK;
        }
        else if CHARS_WHITESPACE.contains(c) {
            last = CharType::WS;
        }
        else if CHARS_CAPS.contains(c) {
            if last != CharType::CAP { words.push(c) }
            last = CharType::CAP;
        }
        else {
            if last != CharType::CAP && last != CharType::WORD { words.push(c) }
            last = CharType::WORD;
        }
    }

    return words.into_iter().collect::<String>();
}

fn main() -> ExitCode {
    let args: Vec<String> = env::args().collect();
    if args.len() != 2 {
        return ExitCode::FAILURE;
    }
    println!("{}", get_short_cwd(args[1].as_str()).as_str());
    ExitCode::SUCCESS
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_shorten_folder() {
        assert_eq!(shorten_folder("folder"), "f");
        assert_eq!(shorten_folder("executables_rust"), "e_r");
        assert_eq!(shorten_folder("AgeOfEmpires"), "AOE");
        assert_eq!(shorten_folder("folderName"), "fN");
        assert_eq!(shorten_folder(".gitignore"), ".g");
        assert_eq!(shorten_folder("LLM"), "L");
        assert_eq!(shorten_folder("LODS_O_EMONE"), "L_O_E");
    }

    #[test]
    fn test_get_short_cwd() {
        assert_eq!(get_short_cwd("/"), "/");
        assert_eq!(get_short_cwd("/home"), "/home");
        assert_eq!(get_short_cwd("/home/gfreeman"), "/h/gfreeman");
        assert_eq!(get_short_cwd("/home/gfreeman/Documents/work"), "/h/g/D/work");
    }
}