---
title: "Getting Started with Hugo"
date: 2024-09-08
draft: false
---
## Obsidian - Why I love it[](https://blog.networkchuck.com/posts/my-insane-blog-pipeline/#obsidian---why-i-love-it)

- Obsidian is the BEST notes application in the world. Go download it: [https://obsidian.md/](https://obsidian.md/)

## The Setup[](https://blog.networkchuck.com/posts/my-insane-blog-pipeline/#the-setup)

- Create a new folder labeled _posts_. This is where you will add your blog posts
- ….that’s all you have to do
- Actually…wait….find out where your Obsidian directories are. Right click your _posts_ folder and choose _show in system explorer_
- You’ll need this directory in upcoming steps.

!![Image Description](https://blog.networkchuck.com/images/Pasted%20image%2020241115145036.png)

# Setting up Hugo[](https://blog.networkchuck.com/posts/my-insane-blog-pipeline/#setting-up-hugo)

## Install Hugo[](https://blog.networkchuck.com/posts/my-insane-blog-pipeline/#install-hugo)

### Prerequisites[](https://blog.networkchuck.com/posts/my-insane-blog-pipeline/#prerequisites)

- Install Git: [https://github.com/git-guides/install-git](https://github.com/git-guides/install-git)
- Install Go: [https://go.dev/dl/](https://go.dev/dl/)

### Install Hugo[](https://blog.networkchuck.com/posts/my-insane-blog-pipeline/#install-hugo-1)

Link: [https://gohugo.io/installation/](https://gohugo.io/installation/)

### Create a new site[](https://blog.networkchuck.com/posts/my-insane-blog-pipeline/#create-a-new-site)

```bash
## Verify Hugo works
hugo version

## Create a new site 

hugo new site websitename
cd websitename
```