# 5stack Inventory

A CS2 inventory and loadout simulator that runs inside your 5stack panel.
Players craft and equip skins, knives, gloves, agents, stickers and charms, and
see them in game on your servers.

## Install

On the machine your 5stack panel runs on, from your `5stack-panel` folder:

```bash
./plugin.sh https://github.com/lukepolo/5stack-inventory-plugin
```

Press Enter at each question to keep the default. When it finishes:

1. **DNS:** point the host it printed (`inventory.<your panel's domain>` by
   default) at the same address as your panel.
2. **Register it:** in the panel, **Settings → Application → Panel Plugins →
   Add**, paste `https://<that host>`, press **Detect**, then save.

Inventory now shows in the panel's sidebar.

## Skins on your game servers

On the Inventory page, an administrator opens the **⚙ settings** button, then
the **Game Server** tab:

1. **Generate key**.
2. **Install and configure**. This installs the CS2 Inventory Simulator plugin
   on your servers and writes its settings for you.

## Item art and 3D models

They are extracted from your own CS2 install the first time the plugin starts.
It takes a while; watch it under **⚙ settings → 3D Models**.

The inventory has to run on a machine that hosts your game servers, because that
is where CS2 is installed.

## Updating

From your `5stack-panel` folder:

```bash
git pull && ./update.sh
./plugin.sh https://github.com/lukepolo/5stack-inventory-plugin
kubectl -n 5stack rollout restart deployment/inventory-backend deployment/inventory-frontend
```

Your answers from the first install are kept. The last line is what picks up the
new version.

## Troubleshooting

| You see | Fix |
| --- | --- |
| A CORS error ending in *must not be the wildcard '\*'* | Update (above). The installer tells the plugin your panel's domain. |
| Nobody is signed in on the Inventory page | The plugin's host has to sit under your panel's domain. Re-run `./plugin.sh` and take the host it offers. |
| **3D Models** says *No CS2 install at /cs2-game* (or *CS2 install not readable*) | The inventory is on a machine without CS2. Move it to one of your game-server machines (below). |

To move the inventory to another machine, see where it is now with
`kubectl get nodes -L 5stack-inventory`, then:

```bash
kubectl label node <current machine> 5stack-inventory-
kubectl label node <game-server machine> 5stack-inventory=true
./plugin.sh https://github.com/lukepolo/5stack-inventory-plugin
kubectl -n 5stack rollout restart deployment/inventory-backend deployment/inventory-frontend
```

## Changing the plugin

How it works, the game-server API, local development and installing by hand are
in [docs/DEVELOPMENT.md](docs/DEVELOPMENT.md).
