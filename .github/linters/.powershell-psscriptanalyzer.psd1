@{
    # Use the built-in default rule set as a baseline
    IncludeDefaultRules = $true

    # Explicit rule configuration
    Rules = @{
        # ── Formatting & style ──────────────────────────────────────────
        PSUseConsistentIndentation = @{
            Enable = $true
            IndentationSize = 4
            Kind = 'space'
            PipelineIndentation = 'IncreaseIndentationForFirstPipeline'
        }

        PSUseConsistentWhitespace = @{
            Enable = $true
            CheckInnerBrace = $true
            CheckOpenBrace = $true
            CheckOpenParen = $true
            CheckOperator = $true
            CheckPipe = $true
            CheckPipeForRedundantWhitespace = $false
            CheckSeparator = $true
            IgnoreAssignmentOperatorInsideHashTable = $true
        }

        PSUseConsistentCasing = @{
            Enable = $true
        }

        # ── Cmdlet / function quality ───────────────────────────────────
        PSUseApprovedVerbs = @{
            Enable = $true
        }

        PSAvoidUsingPlainTextForPassword = @{
            Enable = $true
        }

        PSUseDeclaredVarsMoreThanAssignments = @{
            Enable = $true
        }

        PSAvoidUnusedVariables = @{
            Enable = $true
        }

        # ── Error handling ──────────────────────────────────────────────
        PSAvoidUsingEmptyCatchBlock = @{
            Enable = $true
        }

        # ── Script robustness ───────────────────────────────────────────
        PSProvideCommentHelp = @{
            Enable = $true
            ExportedOnly = $false
            BlockComment = $true
            VSCodeSnippetCorrection = $false
        }

        # ── Security & correctness ──────────────────────────────────────
        PSAvoidUsingInvokeExpression = @{
            Enable = $true
        }

        PSAvoidGlobalVars = @{
            Enable = $true
        }

        # ── Output discipline ───────────────────────────────────────────
        PSAvoidUsingWriteDebug = @{
            Enable = $true
        }
    }

    # Rules to suppress (reduce noise)
    # ────────────────────────────────────────────────────────────────────
    # IMPORTANT: Rules without configurable parameters CANNOT be disabled
    # via Enable = $false inside the Rules hashtable. They MUST be listed
    # here in ExcludeRules to be suppressed.
    # ────────────────────────────────────────────────────────────────────
    ExcludeRules = @(
        'PSAvoidTrailingWhitespace',
        'PSAvoidLongLines',

        # FIX: Was set to Enable = $false in Rules, but that has no effect.
        #      Write-Host is intentional for CLI-style user feedback.
        'PSAvoidUsingWriteHost',

        # FIX: Was set to Enable = $false in Rules, but that has no effect.
        #      ShouldProcess is not required for this script type.
        'PSUseShouldProcessForStateChangingFunctions',

        # FIX: Was set to Enable = $false in Rules, but that has no effect.
        #      Positional parameters are acceptable for CLI scripts.
        'PSAvoidUsingPositionalParameters',

        # FIX: Was set to Enable = $false in Rules, but that has no effect.
        #      Write-Verbose is optional in scripts.
        'PSAvoidUsingWriteVerbose',

        # FIX: Was missing entirely. The init script intentionally uses UTF-8
        #      without BOM for cross-platform compatibility (as documented in
        #      docs/code_style_and_standards_guides.md).
        'PSUseBOMForUnicodeEncodedFile',

        # FIX: Was missing entirely. Functions like Write-Info, Write-Success,
        #      Write-Warn, Write-Die use non-standard verbs by design as
        #      internal helper functions.
        'PSUseSingularNouns'
    )

    # Limit analysis to meaningful severities (useful for CI)
    Severity = @(
        'Error',
        'Warning'
    )
}
