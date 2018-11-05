# How to update your project scaffold

First you need to add scaffold remote repository

```BASH
git remote add scaffold https://github.com/sansible/sansible
git fetch scaffold
```

And now you can diff or checkout selected files

```BASH
# check diff
git diff HEAD..scaffold/scaffold -- Makefile

# checkout latest version
git checkout scaffold/scaffold -- Makefile
```

Simple!
