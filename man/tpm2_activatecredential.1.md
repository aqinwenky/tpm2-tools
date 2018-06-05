% tpm2_activatecredential(1) tpm2-tools | General Commands Manual
%
% AUGUST 2017

# NAME

**tpm2_activatecredential**(1) - verify that an object is protected with a specific
key.

# SYNOPSIS

**tpm2_activatecredential** [*OPTIONS*]

# DESCRIPTION

Verify that the given content is protected with given keyHandle for given
handle, and then decrypt and return the secret, if any password option is
missing, assume NULL. Currently only support using TCG profile compliant EK as
the keyHandle.

# OPTIONS

These options control the object verification:

  * **-c**, **--context**=_OBJ\_CTX\_OR\_HANDLE_:
    _CONTEXT\_OBJECT_ of the content object associated with the created
    certificate by CA.
    Either a file or a handle number. See section "Context Object Format".

  * **-C**, **--key-context**=_KEY\_CONTEXT\_OBJECT_:
    The _KEY\_CONTEXT\_OBJECT_ of the loaded key used to decrypt the random seed.
    Either a file or a handle number. See section "Context Object Format".

  * **-P**, **--auth-key**=_AUTH\_VALUE_:
    Use _AUTH\_VALUE_ for providing an authorization value for the _KEY\_HANDLE_.
    Passwords should follow the authorization formatting standards, see section
    "Authorization Formatting".

  * **-e**, **--endorse-password**=_ENDORSE\_PASSWORD_:
    The endorsement password, optional. Follows the same formatting guidelines as the handle password option -P.

  * **-f**, **--in-file**=_INPUT\_FILE_:
    Input file path, containing the two structures needed by tpm2_activatecredential function. This is created
    via the tpm2_makecredential(1) command.

  * **-o**, **--out-file**=_OUTPUT\_FILE_:
    Output file path, record the secret to decrypt  the certificate.

[common options](common/options.md)

[common tcti options](common/tcti.md)

[context object format](commmon/ctxobj.md)

[authorization formatting](common/password.md)

# EXAMPLES

```
tpm2_activatecredential -c 0x81010002 -C 0x81010001 -P abc123 -e abc123 -f <filePath> -o <filePath>
tpm2_activatecredential -c ak.dat -C ek.dat -P abc123 -e abc123 -f <filePath> -o <filePath>
tpm2_activatecredential -c 0x81010002 -C 0x81010001 -P 123abc -e 1a1b1c -X -f <filePath> -o <filePath>
```

# RETURNS

0 on success or 1 on failure.

[footer](common/footer.md)
