## Contest Scripts

admin_info = data_bag_item("contestenv",node['contestenv']['databag'])['admin_info']

# Create directories
["#{node['contestenv']['util_dir']}/", "#{node['contestenv']['util_dir']}/scripts/"].each do |dir|
  directory dir do
    owner "root"
    group "root"
    mode "0755"
    action :create
  end
end

# Set up the scripts
scripts = %w{firstLogin.sh addPrinter.sh changeTeamName.sh
   clearUser.sh deleteUser.sh
   enableFirewall.sh disableFirewall.sh checkFirewall.sh
   pcpr version_check.sh
   makeDist.sh
}
scripts.each do |s|
    template "#{node['contestenv']['util_dir']}/scripts/#{s}" do
        source "scripts/#{s}.erb"
        owner "root"
        group "root"
        mode "0755"
        variables(
          "admin_username"=>admin_info['username']
        )
    end
end

# Add scripts to the path
template "/etc/profile.d/contest_scripts_path.sh" do
    source "contest_scripts_path.sh.erb"
    mode "0755"
end

# Copy the default wallpaper background
execute "cp \"/dist/wallpaper.png\" \"#{node['contestenv']['util_dir']}/wallpaper.png\"" do
    not_if "test -d \"#{node['contestenv']['util_dir']}/wallpaper.png\""
end

