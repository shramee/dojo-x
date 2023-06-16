<picture>
  <source media="(prefers-color-scheme: dark)" srcset=".github/mark-dark.svg">
  <img alt="Dojo logo" align="right" width="120" src=".github/mark-light.svg">
</picture>

<a href="https://twitter.com/dojostarknet">
<img src="https://img.shields.io/twitter/follow/dojostarknet?style=social"/>
</a>
<a href="https://github.com/dojoengine/dojo">
<img src="https://img.shields.io/github/stars/dojoengine/dojo?style=social"/>
</a>

[![discord](https://img.shields.io/badge/join-dojo-green?logo=discord&logoColor=white)](https://discord.gg/PwDa2mKhR4)
[![Telegram Chat][tg-badge]][tg-url]

[tg-badge]: https://img.shields.io/endpoint?color=neon&logo=telegram&label=chat&style=flat-square&url=https%3A%2F%2Ftg.sumanjay.workers.dev%2Fdojoengine
[tg-url]: https://t.me/dojoengine

# dojo-x-contracts

Contracts for composed autonomous worlds built with Dojo

## Guidelines

The contract are divided into 3 categories,

-   `dao` - DAO contract
-   `universe` - Universe contract
-   `world` - World contract

The categories have these directories

-   `impls` - Implementation
-   `mods` - Mdodules to import
-   `base` - Basic starter contract for implementations
-   `lib.cairo` - Crate emtrypoint

## Interacting With Your Local World

Explore and interact with your locally deployed world! This guide will help you fetch schemas, inspect entities, and execute actions using `sozo`.

If you have followed the example exactly and deployed on Katana you can use the following:

World address: **0xeb752067993e3e1903ba501267664b4ef2f1e40f629a17a0180367e4f68428**

Signer address: **0x06f62894bfd81d2e396ce266b2ad0f21e0668d604e5bb1077337b6d570a54aea**

### Fetching Component Schemas

Let's start by fetching the schema for the `Moves` component. Use the following command, replacing `<world-address>` with your world's address:

```bash
sozo component schema --world 0xeb752067993e3e1903ba501267664b4ef2f1e40f629a17a0180367e4f68428 Moves
```

You should get this in return:

```rust
struct Moves {
   remaining: u8
}
```

This structure indicates that the `Moves` component keeps track of the remaining moves as an 8-bit unsigned integer.

### Inspecting an Entity's Component

Let's check the remaining moves for an entity. In our examples, the entity is based on the caller address, so we'll use the address of the first Katana account as an example. Replace `<world-address>` and `<signer-address>` with your world's and entity's addresses respectively:

```bash
sozo component entity --world 0xeb752067993e3e1903ba501267664b4ef2f1e40f629a17a0180367e4f68428 Moves 0x06f62894bfd81d2e396ce266b2ad0f21e0668d604e5bb1077337b6d570a54aea
```

If you haven't made an entity yet, it will return `0`.

### Adding an Entity

No entity? No problem! You can add an entity to the world by executing the `Spawn` system. Remember, there's no need to pass any call data as the system uses the caller's address for the database. Replace `<world-address>` with your world's address:

```bash
sozo execute --world 0xeb752067993e3e1903ba501267664b4ef2f1e40f629a17a0180367e4f68428 Spawn
```

### Refetching an Entity's Component

After adding an entity, let's refetch the remaining moves with the same command we used earlier:

```bash
sozo component entity --world 0xeb752067993e3e1903ba501267664b4ef2f1e40f629a17a0180367e4f68428 Moves 0x06f62894bfd81d2e396ce266b2ad0f21e0668d604e5bb1077337b6d570a54aea
```

Congratulations! You now have `10` remaining moves! You've made it this far, keep up the momentum and keep exploring your world!
