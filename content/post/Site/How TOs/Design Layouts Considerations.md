### Blog Navigation Restructuring

**Problem**: Default hugo-clarity theme had generic navigation (Home, Archives, Links, About)
**Solution**: Created custom skill-based navigation matching your expertise

##### Key Steps:

1. Identified menu configuration location: *config/default/menus/menu.en.toml*

2. Replaced content with custom structure:
	- Home | Microsoft | Virtualization | Automation | About
	- Added dropdown menus with sub-technologies (Azure, Intune, SCCM, etc.)

3. Deleted Portuguese menu file (*menu.pt.toml*) to eliminate conflicts
4. Added language overrides in *hugo.toml* to force English-only

### Custom Branding Implementation

**Problem**: Site showed "CLARITY" theme name instead of your brand
**Solution**: Created custom logo template with styled text

##### Key Steps:

1. Created *layouts/partials/logo.html* to override theme's logo
2. Used HTML spans for custom styling: Half<span style="color: #ff4444;">On</span>Cloud
3. Applied larger font size (1.8rem) and bold weight for prominence

### Featured Images as Background Banners

**Problem**: Wanted attractive post previews with images behind text, not above it
**Solution**: Modified excerpt template and added custom CSS

##### Key Steps:

1. Copied and modified *layouts/partials/excerpt.html* to support *featureImage* parameter
2. Created *static/css/custom.css* with background image styling
3. Added *customCSS =* ["css/custom.css"] to *hugo.toml* parameters
4. Used *background-size: 120%* for optimal image display
5. Added dark overlay (*rgba(0, 0, 0, 0.6)*) for text readability

### Content Customization

##### Key Actions:

1. Created custom About page at *content/about/index.md* to override theme's default
2. Added *showShare = false* and *socialShare = false* to remove social buttons
3. Set up proper frontmatter format for posts: *featureImage: "images/filename.jpg"*

#### File Structure Created

![[Pasted image 20250910095557.png]]


## Critical Learning Points

1. **Hugo Template Hierarchy:** Local files in `layouts/` override theme files
2. **Menu Configuration:** hugo-clarity uses separate menu files, not inline config
3. **Image Parameters:** Theme uses `featureImage`, not `featured_image`
4. **CSS Integration:** Must reference custom CSS in `hugo.toml` parameters
5. **Template Dependencies:** Archive → Excerpt → Image display chain

