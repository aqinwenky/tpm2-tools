% tpm2_readpublic(1) tpm2-tools | General Commands Manual
%
% SEPTEMBER 2017

# NAME

**tpm2_readpublic**(1) - Read the public area of a loaded object.

# SYNOPSIS

**tpm2_readpublic** [*OPTIONS*]

# DESCRIPTION

**tpm2_readpublic**(1) Reads the public area of a loaded object.

# OPTIONS

  * **-c**, **--context-object**=_OBJECT\_CONTEXT_:

    Context object for the object to read. Either a file or a handle number.
    See section "Context Object Format".

  * **-o**, **--out-file**=_OUT\_FILE_:

    The output file path, recording the public portion of the object.

[context object format](commmon/ctxobj.md)

[pubkey options](common/pubkey.md)

[common options](common/options.md)

[common tcti options](common/tcti.md)

# EXAMPLES

```
tpm2_readpublic -c 0x81010002 -o output.dat
```

# RETURNS

0 on success or 1 on failure.

[footer](common/footer.md)
