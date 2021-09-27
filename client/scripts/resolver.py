# requirements: 
# pip install dnspython

import dns.resolver

def get_all_a_records(domain, resolver_ip):
    a_records = []
    try:
        resolver = dns.resolver.Resolver()
        resolver.nameservers = [resolver_ip]
        answers = resolver.resolve(domain, 'A')
        for answer in answers:
            a_records.append(answer.to_text())
    except dns.resolver.NoAnswer:
        pass
    return a_records

domain = 'google.com'
resolver_ip = '8.8.8.8'
a_records = get_all_a_records(domain, resolver_ip)
print(a_records)