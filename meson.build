# Name our project
project('com.github.lainsce.niu', ['vala', 'c'],
    version: '1.1.1'
)

# Import main lib files
gnome = import('gnome')
i18n = import('i18n')

# Compile the GResources for this project
asresources = gnome.compile_resources(
    'as-resources',
    'data/style.gresource.xml',
    source_dir: 'data',
    c_name: 'as'
)

icon_resources = gnome.compile_resources(
    'gresource_icons',
    'data/icons/icon.gresource.xml',
    source_dir: 'data/icons',
    c_name: 'as'
)

# Set this for convenience
conf = configuration_data()

# Get the package data directory under Meson
pkgdatadir = join_paths([ get_option('prefix'),
                          get_option('datadir'),
                          'com.github.lainsce.niu' ])

conf.set_quoted('PKGDATADIR', pkgdatadir)

# Other configs
conf.set_quoted('GETTEXT_PACKAGE', meson.project_name())
conf
add_global_arguments('-DDATADIR="' + get_option('datadir') + '"', language: 'c')
configure_file(output: 'config.h', configuration: conf)
config_h_dir = include_directories('.')

# Arguments for C
c_args = [
  '-include', 'config.h',
  '-w'
]

cc = meson.get_compiler('c')
m_dep = cc.find_library('m', required: true)

# Let's define our executable
executable(
    meson.project_name(),
    'src/Application.vala',
    'src/MainWindow.vala',
    'src/DBusServer.vala',
    'src/Updater.vala',
    'src/Utils.vala',
    'src/Constants/AppSettings.vala',
    asresources,
    c_args: c_args,
    dependencies: [
        dependency('granite'),
        dependency('gobject-2.0'),
        dependency('gtk+-3.0'),
        m_dep,
    ],
    vala_args: [
        meson.source_root() + '/vapi/config.vapi',
        '--vapidir=' + meson.source_root() + '/vapi/',
    ],
    install : true
)

shared_module(
    'niu',
    'src/Indicator/Indicator.vala',
    'src/Indicator/DBusClient.vala',
    'src/Indicator/Widgets/PopoverWidget.vala',
    'src/Indicator/Widgets/DisplayWidget.vala',
    'src/Indicator/Widgets/Time.vala',
    'src/Indicator/Widgets/Cal.vala',
    'src/Utils.vala',
    'src/Constants/AppSettings.vala',
    icon_resources,
    c_args: c_args,
    dependencies: [
        dependency('glib-2.0'),
        dependency('granite'),
        dependency('gtk+-3.0'),
        dependency('wingpanel-2.0')
    ],
    install: true,
    install_dir : '/usr/lib/x86_64-linux-gnu/wingpanel/'
)

# Add in a post install script
meson.add_install_script('meson/post_install.py')

# Add subfolders for Meson to look
subdir('data')
subdir('po')
