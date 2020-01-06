# Example Stack with Kubernetes, Docker Compose, Sceptre & CloudFormation

An example stack I've made to demo a very basic CRUD application using basic React, NodeJS, Postgres and TypeScript techs. Mostly done for the sake of practise and always for quick scaffolding of my new similar apps.

The two bootstrap projects are also the basic boilerplate I carry around from one project to another:
* https://github.com/TeemuKoivisto/my-node-bootstrap
* https://github.com/TeemuKoivisto/my-react-bootstrap

## Introduction

So there's 3 ways of deploying this stack. Depending on of course what you want to do, I recommend trying out the Docker Compose version first, then Kubernetes and lastly for real production deployment, Sceptre and CloudFormation.

The Docker Compose is somewhat legit way of locally running this type of basic setups with React, NodeJS and Postgres, yet I didn't find a that great way of using HTTPS-certificates locally. The problem often with application stacks is, that they differ from local to production so that there might be errors in production which you didn't see when you ran it locally. Therefore the most common way of ensuring this doesn't happen, is to run dev-environments with almost equal setup as in production. But even that might not always catch every bug, sadly.

What I did here then, is create these stacks for local and production environments. As I mentioned Docker Compose is good for local development, as Kubernetes is sadly too complicated to invest time in unless you're really committed to using it in production also. I had the goal of turning this local Kubernetes setup into a similar Sceptre + CF stack as the ECS-one, but I probably won't have time for it. It's much easier to use ECS and I'm not really interested in moving out of AWS in the near future.

That said, the current Sceptre + CF stack is a production-ready version of this whole thing, which you could in theory use to run your real-life application. I haven't gotten around making a real `prod`-version though, and the `dev`-version is mostly created with minimal cost in mind (1 NAT, minimal ECS tasks and DB instance). But it's ok and definitely enough for small apps. The cost of running using on-demand prices would be 18$ DB + 32$ NAT + x from ECS + y from S3,CloudWatch = ~50-60 * VAT (eg 24%) = 60-80$ depending on your load. Which is quite high for hobby projects, even with discounted reserved instance prices. So you probably should put up some ads to pay the bills or something 🤔. Yeah it's quite ridiculous price for some basic app, so maybe I'll be making some sort of Linode + AWS combo with as low costs as possible. I'll probably do it when I have my own app ready to launch.

If you are new to this stuff take your time. I know the information here is going to overwhelm you, but keep in mind that I built this whole thing over couple years (in maybe 3 different phases). So I've put some time into this! And you probably need too =).

* [Docker](./DOCKER.md)
* [k8s](./K8S.md)
* [Sceptre + CF](./AWS.md)

## Helpful extensions for VSCode

If you're using VSCode which I highly recommend you can install various of extensions to make developing much easier. Here's some of my favourites:

* Docker
* VS Live Share
* nginx.conf hint
* Code Spell Checker

For the TypeScript projects:

* vscode-styled-components
* TSLint
* Import Cost

Also I'm fan of auto-save, put this to your User Settings to enable it:
```
  "files.autoSave": "afterDelay",
  "files.autoSaveDelay": 100,
```
