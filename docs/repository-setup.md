# Repository setup

## Ownership

The customized Evo-RL fork owns reusable framework changes. This repository owns the pick and place task summary, dataset references, task configurations, launch scripts, and experiment records. Future tasks should receive sibling repositories under the parent's `projects/` directory.

## Remote setup

Create an empty remote for this project and a fork of the original Evo-RL repository under the intended account or organization. Avoid publishing local datasets, checkpoints, credentials, or unrelated working files.

Configure the parent fork with its own URL as `origin` and the original Evo-RL URL as `upstream`. Preserve existing work when changing remotes; changing a remote does not save uncommitted customizations.

## Submodule registration

Push a project commit to its own remote first. Then register that remote at `projects/pick-place-parts` from the parent repository and commit the resulting `.gitmodules` and Git submodule entry in the parent fork. The submodule entry pins a project commit; it does not automatically follow the latest remote branch.

New parent checkouts should use `git clone --recurse-submodules`, or run `git submodule update --init --recursive` after cloning. Project changes must be committed and pushed in the project repository before the parent updates its pinned submodule commit.

Do not stage all parent working files when registering this project. Review framework customizations and exclude unrelated environments, large outputs, and installer files.
