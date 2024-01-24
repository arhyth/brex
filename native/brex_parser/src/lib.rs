#[rustler::nif]
fn parse(line: &str) -> Vec<(Vec<u8>, i32)> {
    let mut bytz = line.bytes().peekable();
    let mut cities: Vec<(Vec<u8>, i32)> = Vec::new();
    let mut is_neg = false;

    while let Some(_) = bytz.peek() {
        let mut city: Vec<u8> = Vec::with_capacity(40);
        while let Some(b) = bytz.next() {
            match b {
                b';' => break,
                _ => {
                    city.push(b); 
                }
            }
        }
    
        let mut measure: i32 = 0;
        while let Some(b) = bytz.next() {
            match b {
                b'\n' => {
                    if is_neg {
                        measure = -measure;
                    }
                    break
                },
                b'-' => {
                    is_neg = true;
                },
                b'.' => continue,
                _ => {
                    let d = (b - b'0') as i32;
                    measure = measure * 10 + d;
                }
            }
        }
    
        cities.push((city, measure));
    }
    cities
}

#[rustler::nif]
fn into_valid_chunks<'a, 'b>(raw: &'a str, leftover: &'a str) -> (Vec<String>, &'b str)
where
    'a: 'b,
{
    let emit: Vec<String>;
    let mut newleftover: &str = "";
    if let Some(fi) = raw.find('\n') {
        let li = raw.rfind('\n').unwrap();
        let idx = if li == fi { fi } else { li };
        let valid: &str;
        (valid, newleftover) = raw.split_at(idx+1);
        let mut to_join = String::with_capacity(valid.len() + leftover.len());
        to_join.push_str(leftover);
        to_join.push_str(valid);
        emit = vec![to_join];
    } else {
        emit = vec![leftover.to_owned()];
    }

    (emit, newleftover)
}

rustler::init!("Elixir.Brex.Parser", [parse, into_valid_chunks]);
