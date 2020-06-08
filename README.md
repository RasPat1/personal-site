# A Simple Static Website
---
I've just been running a few experiments and doing a some reasearch on static site generation
as well as the current state of all the basics around running simple websites.

## Deploying
----
Currently, the site is geployed via git push. There is a remote associated with the repo on an nginx box.
The repo has a git post receive hook that will cause it to update and run a build.


## Explore List
---
### Hosting Options
- Digital Ocean (Small cloud provider. linode, etc.)
- AWS (Large Cloud provider. GCP,etc.)
- Heroku
- Github static hosting
- Other static hosting (s3 bucket!, etc.)
### Servers
- Nginx (or Apache)
- Can I use the protocols from IPFS or Protocol Labs, um libp2p I think to host this site? Set up a decentralized website?
- What’s the new hotness? (Can I write my own server for fun?!?)
### Site builder mechanisms
- Raw frontend (0 lib setup)
- Netlify (Static site generators, gatsby?, etc.)
- Github Pages
- html 5 boilerplate
- Ghost (CMS platform setups?)
- Other? (Do some more research. what are the options right now?)
### Tooling
- git post deploy hooks
- docker
- terraform
- Let’s encrypt
- Check out that meta list of SaaS tools. Really need new relic on my static site I think.
- HTTP/2
- 
