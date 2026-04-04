import requests

print("=" * 60)
print("WOUND ANALYSIS MODELS ON HUGGING FACE")
print("=" * 60)
try:
    url = "https://huggingface.co/api/models?search=wound&sort=downloads&direction=-1&limit=20"
    response = requests.get(url, timeout=20)
    models = response.json()
    for m in models:
        print(f"\n  Model  : {m.get('id')}")
        print(f"  DLs    : {m.get('downloads')}")
        tags = m.get('tags', [])
        print(f"  Tags   : {', '.join(tags[:6])}")
except Exception as e:
    print("Error:", e)

print("\n" + "=" * 60)
print("WOUND DATASETS ON HUGGING FACE")
print("=" * 60)
try:
    url_ds = "https://huggingface.co/api/datasets?search=wound&sort=downloads&direction=-1&limit=10"
    response_ds = requests.get(url_ds, timeout=20)
    datasets = response_ds.json()
    for d in datasets:
        print(f"\n  Dataset: {d.get('id')}")
        print(f"  DLs    : {d.get('downloads')}")
except Exception as e:
    print("Error:", e)

print("\n" + "=" * 60)
print("GITHUB REPOS — WOUND CLASSIFICATION/DETECTION")
print("=" * 60)
try:
    gh_url = "https://api.github.com/search/repositories?q=wound+classification+OR+wound+detection+machine+learning&sort=stars&order=desc"
    gh_response = requests.get(gh_url, timeout=20)
    gh_repos = gh_response.json().get('items', [])[:12]
    for repo in gh_repos:
        print(f"\n  Repo : {repo.get('full_name')}")
        print(f"  Stars: {repo.get('stargazers_count')}")
        print(f"  Desc : {repo.get('description')}")
        print(f"  Lang : {repo.get('language')}")
        print(f"  URL  : https://github.com/{repo.get('full_name')}")
except Exception as e:
    print("Error:", e)

print("\nDONE")
