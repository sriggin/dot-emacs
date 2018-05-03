;;; .emacs --- Sean's .emacs file

;;; Commentary:
;;; This file contains a snapshot of my configuration of Emacs

;;; Code:
(require 'package)

;;;; Global Things

(setq package-archives '(("gnu" . "https://elpa.gnu.org/packages/")
                         ("marmalade" . "https://marmalade-repo.org/packages/")
                         ("melpa" . "https://melpa.org/packages/")
                         ("melpa-stable" . "https://stable.melpa.org/packages/")))

(package-initialize)

;;;; Strip out UI elements
(show-paren-mode t)
(scroll-bar-mode 0)
(blink-cursor-mode 0)
(tool-bar-mode 0)
(menu-bar-mode 0)

(setq-default inhibit-scratch-message nil
              initial-scratch-message ""
              indent-tabs-mode nil
              tab-width 4
              tab-always-indent 'complete)
(setq inhibit-startup-message t
      inhibit-startup-screen t
      ring-bell-function 'ignore
      visible-bell t
      inhibit-startup-echo-area-message "sriggin"
      backup-by-copying t
      backup-directory-alist '(("." . "~/.saves"))
      delete-old-versions t
      kept-new-versions 6
      kept-old-versions 2
      version-control t
      max-lisp-eval-depth 10000)

(electric-indent-mode t)
(electric-pair-mode t)
(electric-layout-mode t)

(defalias 'yes-or-no-p 'y-or-n-p)

;;; Package Configuration

(use-package ensime
  :commands ensime-mode
  :config
  (setq ensime-startup-notification nil
        ensime-log-events t)
  :bind ("M-." . ensime-edit-definition-with-fallback))

(use-package flycheck
  :ensure t
  :commands flycheck-mode global-flycheck-mode
  :diminish "FlyC"
  :config
  (use-package flycheck-pos-tip
    :config
    (setq flycheck-pos-tip-timeout 7
          flycheck-display-errors-delay 0.5)
    (flycheck-pos-tip-mode +1))
  (define-fringe-bitmap 'flycheck-fringe-bitmap-double-arrow
    [0 0 0 0 0 256 384 448 480 496 480 448 384 256 0 0 0 0 0]
    ))

(use-package ggtags
  :ensure t)

(use-package projectile
  :ensure t
  :commands projectile-mode
  :config
  (setq projectile-use-git-grep t
        projectile-tags-backend 'ggtags)
  :bind
  (("C-c f" . projectile-find-file)
   ("C-c C-f" . projectile-grep)))

(use-package undo-tree
  :commands undo-tree-mode
  :bind
  ("C-?" . undo-tree-visualize))

(use-package ido
  :ensure t
  :commands ido-mode
  :bind (:map ido-file-dir-completion-map
              ("C-c C-s" . (lambda()
                             (interactive)
                             (ido-initiate-auto-merge (current-buffer)))))
  :init
  (ido-mode)
  :config
  (setq ido-auto-merge-work-directories-length -1)
  (use-package flx-ido
    :ensure t
    :init
    (flx-ido-mode)
    :config
    (setq ido-enable-flex-matching t
          ido-show-dot-for-dired nil
          ido-enable-dot-prefix t))
  (use-package ido-vertical-mode
    :ensure t
    :init
    (ido-vertical-mode))) ;; this keeps ido from searching globally

(use-package smex
  :ensure t
  :bind ("M-x" . smex))

;; Allows highlighting the current symbol
(use-package highlight-symbol
  :diminish highlight
  :bind ("C-c h" . highlight-symbol))

;; Go to last change after moving around (i.e. while reading bad code)
(use-package goto-chg
  :commands goto-last-change
  ;; complementary to
  ;; C-x r m / C-x r l
  ;; and C-<space> C-<space> / C-u C-<space>
  :bind (("C-." . goto-last-change)
         ("C-," . goto-last-change-reverse)))

(use-package magit
  :ensure t
  :commands (magit-status magit-blame)
  :config (magit-auto-revert-mode nil)
  :bind (("C-c C-g s" . magit-status)
         ("C-c C-g b" . magit-blame)))

(use-package company
  :ensure t
  :commands company-mode
  :config
  (setq company-idle-delay 0
        company-minimum-prefix-length 4)
  (use-package company-dabbrev
    :config
    (setq company-dabbrev-ignore-case nil
          company-dabbrev-downcase nil)))

(use-package yasnippet
  :ensure t
  :diminish yas
  :commands yas-minor-mode
  :config
  (yas-reload-all))

(use-package etags-select
  :commands etags-select-find-tag)

(use-package ace-jump-mode
  :ensure t
  :init
  (define-key global-map (kbd "C-c SPC") 'ace-jump-mode))

;; Rust Support

(use-package rust-mode
  :mode "\\.rs\\'"
  :commands rust-mode
  :config
  (setq rust-format-on-save t)
  (use-package flycheck-rust
    :after flycheck
    :commands flycheck-rust-setup
    :hook flycheck-rust-setup)
  (use-package cargo
    :commands cargo-minor-mode
    :diminish cargo)
  (use-package racer
    :commands racer-mode
    :hook (racer-mode eldoc-mode)
    :bind (:map rust-mode-map
                ("M-." . racer-find-definition))
    :config
    (use-package company-racer
      :config
      (add-to-list 'company-backends 'company-racer)
      (setq company-tooltip-align-annotations t))))

(use-package toml-mode
  :mode "\\.toml\\'")

(use-package js2-mode
  :mode "\\.js\\'"
  :hook (js2-imenu-extras-mode)
  :config
  (add-hook 'js2-mode-hook (lambda () (flycheck-select-checker 'javascript-eslint))))

(use-package tern-mode
  :commands tern-mode
  :diminish tern
  :config
  (add-hook 'js-mode-hook 'tern-mode)
  (add-to-list 'company-backends 'company-tern))

;(use-package tide
;  :hook (tide-setup flycheck-mode eldoc-mode tide-hl-identifier-mode tern-mode company-mode)
;  :config
;  (add-hook 'before-save-hook 'tide-format-before-save)
;  (setq company-tooltip-align-annotations t
;        flycheck-check-syntax-automatically '(save mode-enabled))
;  (use-package company-tern
;    :config
;    (add-to-list 'company-backends 'company-tern)
;    :bind (:map tern-mode-keymap
;                ("M-." . nil)
;                ("M-," . nill))))

(use-package haskell-mode)

(use-package scala-mode
  :ensure t
  :bind ("RET" . scala-mode-newline-comments))

(add-hook 'prog-mode-hook
          (lambda ()
            (yas-minor-mode)
            (hs-minor-mode)
            (subword-mode)
            (projectile-mode)
            (flycheck-mode)))

;(use-package prog-mode
;  :hook (yas-minor-mode hs-minor-mode subword-mode projectile-mode flycheck-mode))

(use-package drag-stuff
  :ensure t
  :init (drag-stuff-global-mode t))

(use-package powerline
  :ensure t
  :init (powerline-default-theme))

(use-package cl-lib)

(use-package color)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun contextual-backspace ()
  "Hungry whitespace or delete work depending on context."
  (interactive)
  (if (looking-back "[[:space:]\n]\\{2,\\}" (- (point) 2))
      (while (looking-back "[[:space:]\n]" (- (point) 1))
        (delete-char -1))
    (cond
     ((boundp 'smart-parens-strict-mode)
      (sp-backward-kill-work 1))
     ((and (boundp 'subword-mode)
           subword-mode)
      (subword-backward-kill 1))
     (t
      (backward-kill-word 1)))))

(defun ensime-edit-definition-with-fallback ()
  "Variant of `ensime-edit-definition' with ctags if ENSIME is not available."
  (interactive)
  (unless (and (ensime-connection-or-nil)
               (ensime-edit-definition))
    (projectile-find-tag)))

(defun scala-mode-newline-comments ()
  "Custom newline appropriate for `scala-mode'."
  (interactive)
  (newline-and-indent)
  (scala-indent:insert-asterisk-on-multiline-comment))

(global-set-key (kbd "C-<backspace>") 'contextual-backspace)
(global-set-key (kbd "M-,") 'pop-tag-mark)

(add-hook 'hs-minor-mode-hook (lambda ()
                                (local-set-key (kbd "C-c C-h") 'hs-hide-block)
                                (local-set-key (kbd "C-c C-s") 'hs-show-block)
                                (local-set-key (kbd "C-c C-S-h") 'hs-hide-all)
                                (local-set-key (kbd "C-c C-S-s") 'hs-show-all)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Customizations.. leave it alone
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Emacs-manged stuff
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-enabled-themes (quote (spolsky)))
 '(custom-safe-themes
   (quote
    ("c48551a5fb7b9fc019bf3f61ebf14cf7c9cdca79bcb2a4219195371c02268f11" "0c29db826418061b40564e3351194a3d4a125d182c6ee5178c237a7364f0ff12" "e26780280b5248eb9b2d02a237d9941956fc94972443b0f7aeec12b5c15db9f3" default)))
 '(ensime-log-events t)
 '(flx-ido-mode t)
 '(haskell-mode-hook
   (quote
    (turn-on-haskell-decl-scan turn-on-haskell-doc turn-on-haskell-indentation)))
 '(js-indent-level 2)
 '(js2-basic-offset 2)
 '(package-selected-packages
   (quote
    (ggtags undo-tree magit js2-refactor js2-mode yaml-mode company-tern tide org-present smex flycheck-pos-tip rainbow-delimiters flycheck highlight-symbol projectile ido-vertical-mode flx-ido toml-mode cargo racer rust-mode darkroom ace-jump-mode markdown-mode sublime-themes ensime use-package drag-stuff haskell-mode powerline scala-mode)))
 '(sbt:ansi-support t))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:inherit nil :stipple nil :background "#161A1F" :foreground "#DEDEDE" :inverse-video nil :box nil :strike-through nil :overline nil :underline nil :slant normal :weight normal :height 140 :width normal :foundry "unknown" :family "Droid Sans Mono"))))
 '(ensime-errline-highlight ((t (:inherit flymake-errline))))
 '(hl-line ((t (:inherit highlight :background "#151515" :underline nil))))
 '(sbt:error ((t (:inherit error)))))

;;;; Specific to OSX, since Apple make the best laptops, even if I strongly dislike MacOS
(when (eq system-type 'darwin)
  (setq mac-option-modifier 'meta
        mac-command-modifier 'meta)
  (set-face-attribute 'default nil :family "Droid Sans Mono for Powerline")) ; This font was in the list when I checked.

;;; .emacs ends here
