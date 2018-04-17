% tpm2_createek(1) tpm2-tools | General Commands Manual
%
% SEPTEMBER 2017

# NAME

**tpm2_createek**(1) - Generate TCG profile compliant endorsement key.

# SYNOPSIS

**tpm2_createek** [*OPTIONS*]

# DESCRIPTION

**tpm2_createek**(1) - Generate TCG profile compliant endorsement key (EK), which is the primary object
of the endorsement hierarchy. If any password option is missing, assume NULL for the password.

Refer to:
<http://www.trustedcomputinggroup.org/files/static_page_files/7CAA5687-1A4B-B294-D04080D058E86C5F>

# OPTIONS

  * **-e**, **--auth-endorse**=_ENDORSE\_AUTH_:
    Specifies current endorsement authorization.
    authorizations should follow the "authorization formatting standards, see section
    "Authorization Formatting".

  * **-P**, **--auth-ek**=_EK\_AUTH_
    Specifies the EK authorization when created.
    Same formatting as the endorse authorization value or **-e** option.

  * **-o**, **--auth-owner**=_OWNER\_AUTH_
    Specifies the current owner authorization.
    Same formatting as the endorse password value or **-e** option.

  * **-H**, **--handle**=_HANDLE_:
    Optional, specifies the handle used to make EK persistent (hex).
    If a value of **-** is passed the tool will find a vacant persistent handle
    to use and print out the automatically selected handle.

  * **-c**, **--context**=_PATH_:
    Optional, specifies a path to save the context of the EK handle. If one saves
    the context file via this option and the public key via the **-p** option, the
    EK can be restored via a call to tpm2_loadexternal(1).

  * **-g**, **--algorithm**=_ALGORITHM_:
    specifies the algorithm type of EK.
    See section "Supported Public Object Algorithms" for a list of supported
    object algorithms. See section "Algorithm Specifiers" on how to specify
    an algorithm argument.

  * **-p**, **--file**=_FILE_:
    Optional: specifies the file used to save the public portion of EK. This defaults
    to a binary data structure corresponding to the TPM2B_PUBLIC structure in the
    specification. Using the **--format** option allows one to change this
    behavior.

  * **-S**, **--session**=_SESSION\_FILE_:

    Optional, A session file from **tpm2_startauthsession**(1)'s **-S** option.

[pubkey options](common/pubkey.md)

[common options](common/options.md)

[common tcti options](common/tcti.md)

[supported public object algorithms](common/object-alg.md)

[algorithm specifiers](common/alg.md)

# EXAMPLES
## With a Resource Manager (RM)

Resource managers will flush the TPM context when a tool exits, thus
when using an RM, moving the created EK to persistent memory is
required.

Create an Endorsement Key and make it persistent:
```
tpm2_createek -e abc123 -o abc123 -P passwd -H 0x81010001 -g rsa -f ek.pub
```

## Without a Resource Manager (RM)

The following examples will not work when an RM is in use, as the RM will
flush the TPM context when the tool exits. In these scenarios, the created
EK is in transient memory and thus will be flushed.

Create an Endorsement Key and make it transient:
```
tpm2_createek -g rsa
```

Create a transient Endorsement Key, flush it, and reload it.
```
tpm2_createek -g rsa -p ek.pub -c ek.ctx

# Check that it is loaded in transient memory
tpm2_getcap -c handles-transient
- 0x80000000

# Flush the handle
tpm2_flushcontext -H 0x80000000

# Note that it is flushed
tpm2_getcap -c handles-transient
<null output>

# Reload it via loadexternal
tpm2_loadexternal -H o -u ek.pub -C ek.ctx

# Check that it is re-loaded in transient memory
tpm2_getcap -c handles-transient
- 0x80000000

```

# RETURNS

0 on success or 1 on failure.

[footer](common/footer.md)
