# GitMan (Git Manager)

GitMan provides essential git commands that have become too large to share in a simple text file. It streamlines your
git workflow by offering convenient tools for managing branches.

## Installation

### Step 1: Add the Repository

To add the GitMan repository to your system, run the following command:

```bash
echo "deb [trusted=yes] https://clownmeister.github.io/gitman stable main" | sudo tee /etc/apt/sources.list.d/gitman.list > /dev/null
```

### Step 2: Install GitMan

Once the repository is added, update your package list and install GitMan:

```bash
sudo apt update
sudo apt install gitman
```

## Available Commands

Here are the commands you can use with GitMan:

| Command        | Description                                                                                    |
|----------------|------------------------------------------------------------------------------------------------|
| `gitman clear` | Safely deletes all local branches. **Does not** delete branches with changes against upstream. |
| `gitman sync`  | Fetches and pulls all local branches iteratively.                                              |
| `gitman merge` | Fetches the latest remote state of a specified branch and merges it into the current branch.   |

## Usage

After installation, you can start using GitMan to manage your local git branches efficiently.

For more information on specific commands, refer to the command help or documentation.
