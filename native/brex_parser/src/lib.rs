#[rustler::nif]
fn parse(line: Vec<u8>) -> Vec<(Vec<u8>, i32)> {
    let mut bytz = line.iter().peekable();
    let mut cities: Vec<(Vec<u8>, i32)> = Vec::new();
    let mut is_neg = false;

    while let Some(_) = bytz.peek() {
        let mut city: Vec<u8> = Vec::with_capacity(40);
        while let Some(b) = bytz.next() {
            match b {
                b';' => break,
                _ => {
                    city.push(*b); 
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
fn into_valid_chunks(raw: Vec<u8>, leftover: Vec<u8>) -> (Vec<Vec<u8>>, Vec<u8>) {
    let mut iter = raw.iter();
    let firstnl = iter.position(|&b| b == b'\n');
    let lastnl = iter.rposition(|&b| b == b'\n');

    let mut valid: Vec<u8>;
    let mut newleftover: Vec<u8>;

    if let Some(fi) = firstnl {
        let li = lastnl.unwrap();
        match li {
            _same if li == fi => {
                let (chunk, newlo) = raw.split_at(fi+1);
                valid = Vec::with_capacity(leftover.len() + chunk.len());
                valid.extend_from_slice(&leftover);
                valid.extend_from_slice(&chunk);
                newleftover = newlo.to_vec();
            }
            _ => {
                let (chunk, newlo) = raw.split_at(li+1);
                valid = Vec::with_capacity(leftover.len() + chunk.len());
                valid.extend_from_slice(&leftover);
                valid.extend_from_slice(&chunk);
                newleftover = newlo.to_vec();
            }
        }
    } else {
        valid = Vec::with_capacity(0);
        newleftover = Vec::with_capacity(leftover.len() + raw.len());
        newleftover.extend_from_slice(&leftover);
        newleftover.extend_from_slice(&raw);
    }

    (vec![valid], newleftover)
}

rustler::init!("Elixir.Brex.Parser", [parse, into_valid_chunks]);
