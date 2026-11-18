# Repository setup

## Independent repositories

[pick-place-parts](https://github.com/Inmetherigersniffstherose/pick-place-parts) is a standalone public repository on the owner's GitHub profile. [Evo-RL](https://github.com/Inmetherigersniffstherose/Evo-RL) is the customized framework repository. Their READMEs link to each other; neither repository needs to contain the other.

The framework owns reusable training and robot integration code. This project owns task documentation, dataset references, configurations, experiment records, and a source archive of the customized project drivers. Additional tasks can have their own repositories alongside these two.

## Clone the project

Run these commands from the directory where you keep your projects:

```bash
git clone https://github.com/Inmetherigersniffstherose/Evo-RL.git
git clone https://github.com/Inmetherigersniffstherose/pick-place-parts.git
```

The resulting `Evo-RL/` and `pick-place-parts/` directories are siblings. Each has its own history and remote. Commit and push changes from the repository that owns them.

Cloning does not install hardware support. Follow [the hardware guide](hardware-setup.md) to select the hardware-enabled runtime and configure device paths.

## Reproducibility

Record the framework revision, project revision, dataset revision, and checkpoint for each experiment. Because the repositories are independent, a project commit does not automatically pin a framework revision. Use the experiment record template to preserve the exact combination.

The customized framework uses its own GitHub repository as `origin` and the original MINT-SJTU/Evo-RL repository as `upstream`.
