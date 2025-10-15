# Jekyll plugin: resolve color names in pre-template.yml to hex codes in template.yml
# Usage: rename your current template.yml to pre-template.yml, and this plugin will generate template.yml with resolved hex codes.

require 'yaml'

module Jekyll
  class PaletteResolver < Generator
    safe true
    priority :highest

    def generate(site)
      pre_template_path = File.join(site.source, '_data', 'pre-template.yml')
      template_path = File.join(site.source, '_data', 'template.yml')
      return unless File.exist?(pre_template_path)

      pre_data = YAML.load_file(pre_template_path)
      palette = pre_data['palette'] || {}
      colors = pre_data['color'] || {}

      resolved = {}
      colors.each do |key, value|
        # If the value is a palette name, replace it with the hex code
        if palette.key?(value)
          resolved[key] = palette[value]
        else
          resolved[key] = value
        end
      end

      # Copy everything else from pre-template.yml except palette and color
      output = pre_data.reject { |k, _| k == 'palette' || k == 'color' }
      output['color'] = resolved

      # Write resolved template.yml for use by the rest of the site
      File.open(template_path, 'w') { |f| f.write(output.to_yaml) }
      # Also make available as site.data['resolved_colors'] if needed
      site.data['resolved_colors'] = resolved
    end
  end
end
