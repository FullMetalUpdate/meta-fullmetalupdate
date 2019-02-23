<img src=fmu_logo.png width=375 height=100 />

This README file contains information on the contents of the
meta-fullmetalupdate layer.

Please see the corresponding sections below for details.

# Dependencies

This layer depends on:

  URI: git://git.openembedded.org/bitbake
  branch: rocko

  URI: https://git.yoctoproject.org/git/poky
  layers: meta
  branch: master

  URI: https://git.yoctoproject.org/git/poky
  layers: meta-poky
  branch: master

  URI: https://github.com/openembedded/meta-openembedded
  layers: meta-oe
  branch: rocko

  URI: https://github.com/openembedded/meta-openembedded
  layers: meta-filesystems
  branch: rocko

  URI: https://github.com/openembedded/meta-openembedded
  layers: meta-python
  branch: rocko

  URI: https://github.com/advancedtelematic/meta-updater
  layers: meta-updater
  branch: rocko

# Patches

Please submit any patches against the meta-fullmetalupdate-extra layer to the
https://github.com/FullMetalUpdate/meta-fullmetalupdate/pulls/

Maintainer: Georges Savoundararadj <gsavoundararadj@witekio.com>

# Generate containers

Generate the filesystem with all the containers you need for your final
system using the following command:
```
    DISTRO=fullmetalupdate-containers bitbake fullmetalupdate-containers-package
```

# Generate fullmetalupdate-os

Generate the complete system with the upgrade system using the following
command:
```
    DISTRO=fullmetalupdate-os bitbake fullmetalupdate-os-package
```

To get started, check the documentation:
[Get Started](https://www.fullmetalupdate.io/docs/documentation/)

# Documentation for Embedded Linux

See [Documentation](https://www.fullmetalupdate.io/docs/documentation/)

# Contribute

See [Contribute](https://www.fullmetalupdate.io/docs/contribute/)

# Contact us

* Want to chat with the team behind the dockerfiles for FMU? [Chat room](https://gitter.im/fullmetalupdate/community).
* Having issues with FullMetalUpdate? Open a [GitHub issue](https://github.com/FullMetalUpdate/dockerfiles/issues).
* You can also check out our [Project Homepage](https://www.fullmetalupdate.io/) for further contact options.
