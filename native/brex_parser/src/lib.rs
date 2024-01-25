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

rustler::init!("Elixir.Brex.Parser", [parse]);
