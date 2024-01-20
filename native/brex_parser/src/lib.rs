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
    if let Some(i) = raw.find('\n') {
        let (valid, newleftover) = raw.split_at(i+1);
        let mut to_join = String::with_capacity(valid.len() + leftover.len());
        to_join.push_str(leftover);
        to_join.push_str(valid);
        let to_emit: Vec<String> = vec![to_join];
        let result = (to_emit, newleftover);
        return result
    }
    let to_emit: Vec<String> = vec![leftover.to_owned()];
    (to_emit, "")
}

rustler::init!("Elixir.Brex.Parser", [parse, into_valid_chunks]);
