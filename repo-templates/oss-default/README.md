{% if project == '.github' %}

# Readme for the {{organization}} {{project}} project
Repository for default community health files

[What the hell is this?](https://help.github.com/en/articles/creating-a-default-community-health-file-for-your-organization)

{% else %}

<p align="center"><img src="https://github.com/pavedroad-io/kevlar-repo/blob/master/assets/images/banner.png" alt="PavedRoad.io"></p>

# Readme for the {{organization}} {{project}} project
## Overview
PavedRoad.io is an OSS project for modeling the Software Development and Operations (SDO) lifecycle.  While Infrastrucutre as Code (IaC) gave us the ability to model our servcie, networks, storage, and compute resources.  PavedRoad.io introduces Stacks as Code (SaC) which encomples the entire tool network including library's, development tools, CI/CD, operations, and advance analytics using ML/AI. 

## What is a 'Paved Road'?
The term "Paved Road" was coined by the Netflix tools teams which created several fully integrated end-to-end tool networks for writing, testing, deploying, and operating their streaming video service. For each support execution framework such as Java, Python, or Go, an integrated working CI/CD tool network was created.  This method of pre-integrated and tested tool networks converts a bumpy and difficult road into a delightfully smooth road which dramatically increases the velocity of development teams

## Kevlar for GO
Kevlar a foundation for delivering microservices, serverless functions, and integrating existing traditional and cloud applications, aka bare-metal and virtual machines.  It comes with a complete integrated tool network for developing, deploying, and operating those services. 

## Stacks as Code (SaC)
Infrastructure as Code (IaC) is the process of managing and provisioning computer data centers through machine-readable definition files, rather than physical hardware configuration or interactive configuration tools [Wikipedia](https://en.wikipedia.org/wiki/Infrastructure_as_code).

In SaC, we first automate the entire tool chain by using Kubernetes Custom Resource Definitions (CRD) as an abstraction layers/data model between each step.  Kuberentes metadata provides an abstraction layer for passing data between each step.  Customer controllers manage the flow and create a data presentation layer for tools making up the chain.  This enables the tool network to be formed using standard k8s labels and selectors.

## Getting Started and Documentation

For getting started guides, installation, deployment, and administration, see our [Documentation](https://{{project}}/docs/latest).

## Contributing

PavedRoad.io is a community driven project and we welcome contributions. See [Contributing](CONTRIBUTING.md) to get started.

## Report a Bug

For filing bugs, suggesting improvements, or requesting new features, please open an [issue](https://github.com/{{organization}}/{{project}}/issues).

## Contact

Please use the following to reach members of the community:

- Slack: Join our [slack channel](https://slack.{{organization}})
- Forums: [{{organization}}-dev](https://groups.google.com/forum/#!forum/{{organization}}-dev)
- Twitter: [@{{organization}}](https://twitter.com/{{organization}})
- Email: [info@{{organization}}](mailto:info@{{organization}})

## Community Meeting

A regular community meeting takes place every other [Tuesday at 9:00 AM PT (Pacific Time)](https://zoom.us/{{zoom_meeting_id}}).
Convert to your [local timezone](http://www.thetimezoneconverter.com/?t=9:00&tz=PT%20%28Pacific%20Time%29).

Any changes to the meeting schedule will be added to the [agenda doc]({{agenda_link}}) and posted to [Slack #announcements](https://{{organization}}.slack.com/messages/CEFQCGW1H/) and the [{{organization}}-dev mailing list](https://groups.google.com/forum/#!forum/{{organization}}-dev).

Anyone who wants to discuss the direction of the project, design and implementation reviews, or general questions with the broader community is welcome and encouraged to join.

* Meeting link: https://zoom.us/{{zoom_link}}
* [Current agenda and past meeting notes]({{agenda_link}})
* [Past meeting recordings]({{youtube_link}})

## Project Status

The project is an early preview. We realize that it's going to take a village to arrive at the vision of a multi-cloud control plane, and we wanted to open this up early to get your help and feedback. Please see the [Roadmap](ROADMAP.md) for details on what we are planning for future releases. 

### Official Releases


## Licensing

PavedRoad.io is under the Apache 2.0 license.
{% endif %}

{% include 'do-not-edit.md' %}