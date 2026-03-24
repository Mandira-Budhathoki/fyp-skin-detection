from main_server import app
with open('routes_log.txt', 'w') as f:
    for rule in app.url_map.iter_rules():
        f.write(f"Rule: {rule}, Endpoint: {rule.endpoint}\n")
print("Routes written to routes_log.txt")
