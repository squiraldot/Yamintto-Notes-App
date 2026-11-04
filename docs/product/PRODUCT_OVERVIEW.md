# Product overview

Yamintto is an independent offline-first Flutter notes application for Android and iOS. It is not a conversion or replacement of the separate YRNotes web application; YRNotes remains untouched. The goal is to independently implement note/folder management, Markdown editing, organization, productivity, encryption/recovery, biometric protection and portable backups.

Current implementation is only an application foundation shell: bootstrap, root Riverpod scope, Material 3 system light/dark theme, one GoRouter foundation route/screen, one widget test and native host scaffolds. Product workflows, database, encryption, biometrics, attachments and backups are not implemented.

Core principles: local-first use; transactional data integrity; explicit migration and backup behavior; reviewed authenticated encryption; both password and recovery-key recovery; separate app/vault biometric scopes; accessible cross-platform UX; phase-gated AI-assisted development.

Legacy YRNotes ZIP import is a target feature, not verified compatibility. Inspect the old source and real archive fixtures before specifying importer behavior. Never infer format, Markdown semantics or data compatibility from file extension alone.
