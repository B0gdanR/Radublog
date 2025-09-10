### Configuration Files

**Path**: *C:\Users\Radu\Documents\Radublog\hugo.toml*
**Action**: Modified multiple times
Final Content:

```
baseURL = 'https://halfoncloud.com/'
languageCode = 'en-us'
title = 'HalfOnCloud'
theme = 'hugo-clarity'

[taxonomies]
  tag = "tags"
  category = "categories"

[params]
  description = "IT tutorials, automation scripts, and Microsoft technology insights"
  showShare = false
  socialShare = false
  logo = ""
  customCSS = ["css/custom.css"]

disableLanguages = ["pt"]
defaultContentLanguage = "en"
defaultContentLanguageInSubdir = false
```

**Path**: *C:\Users\Radu\Documents\Radublog\config\_default\menus\menu.en.toml*
**Action**: Modified (replaced entire content)
Content: Custom navigation structure with Microsoft/Virtualization/Automation dropdowns

**Path**: *C:\Users\Radu\Documents\Radublog\config\_default\menus\menu.pt.toml*
**Action**: Deleted (removed to eliminate conflicts)

### Layout Templates
**Path**: C:\Users\Radu\Documents\Radublog\layouts\partials\logo.html
**Action**: Created new file Content:

```
{{- $t := site.Title -}}
<a href='{{ absLangURL "" }}' class="nav_brand nav_item{{ with .class }} {{ . }}{{ end }}" title="{{ $t }}">
  <span style="font-size: 1.8rem; font-weight: bold;">Half<span style="color: #ff4444;">On</span>Cloud</span>
  {{- if ne (strings.HasSuffix .class "center") true }}
  <div class="nav_close">
    <div>
      {{- partialCached "sprite" (dict "icon" "open-menu") -}}
      {{- partial "sprite" (dict "icon" "closeme") -}}
    </div>
  </div>
  {{- end }}
</a>
```


**Path**: *C:\Users\Radu\Documents\Radublog\layouts\_default\single.html*
**Action**: Copied and modified (commented out featured image section)
Source: Copied from themes\hugo-clarity\layouts\_default\single.html

**Path**: *C:\Users\Radu\Documents\Radublog\layouts\partials\archive.html*
**Action**: Copied (no modifications made)
Source: Copied from themes\hugo-clarity\layouts\partials\archive.html

**Path**: *C:\Users\Radu\Documents\Radublog\layouts\partials\excerpt.html*
**Action**: Copied and heavily modified for background image support
Source: Copied from themes\hugo-clarity\layouts\partials\excerpt.html

### Static Assets

**Path**: *C:\Users\Radu\Documents\Radublog\static\css\custom.css*
**Action**: Created new file Content:

```
/* Background image for post previews */
.excerpt_bg {
    background-size: 120%;
    background-position: center center;
    background-repeat: no-repeat;
    padding: 20px;
    border-radius: 8px;
    position: relative;
    min-height: 120px;
}

.excerpt_bg::before {
    content: '';
    position: absolute;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    background: rgba(0, 0, 0, 0.6);
    border-radius: 8px;
}

.excerpt_bg .excerpt_header,
.excerpt_bg .excerpt_footer,
.excerpt_bg .pale {
    position: relative;
    z-index: 2;
    color: white;
}

.excerpt_bg .post_link a {
    color: white;
}
```


**Path**: C:\Users\Radu\Documents\Radublog\static\images\ballpoint-pen.jpg
Action: Added new image file (136 KB)

### Content Files

**Path**: *C:\Users\Radu\Documents\Radublog\content\about\index.md*
**Action**: Created new file
Content: Custom About page with personal information

**Path**: *C:\Users\Radu\Documents\Radublog\content\post\This is my Second blog post.md*
**Action**: Modified frontmatter
Addition: featureImage: "images/ballpoint-pen.jpg"

### Directories Created

**Path**: *C:\Users\Radu\Documents\Radublog\layouts\partials*
**Action**: Created directory

**Path**: *C:\Users\Radu\Documents\Radublog\layouts\_default*
**Action**: Created directory

**Path**: *C:\Users\Radu\Documents\Radublog\static\css*
**Action**: Created directory

**Path**: *C:\Users\Radu\Documents\Radublog\static\images*
**Action**: Created directory

**Path**: *C:\Users\Radu\Documents\Radublog\content\about*
**Action**: Created directory

### Files Attempted But Not Used
**Path**: *C:\Users\Radu\Documents\Radublog\layouts\partials\header.html*
**Action**: Created empty file, then deleted (caused navigation to disappear)
### Theme Files Referenced But Not Modified
**Path**: *C:\Users\Radu\Documents\Radublog\themes\hugo-clarity\exampleSite\config\_default\menus\menu.en.toml*
**Action**: Renamed to .bak to disable theme's default menu