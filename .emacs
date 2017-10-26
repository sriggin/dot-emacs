(require 'package)

;;;; Global Things

(setq package-archives '(("gnu" . "http://elpa.gnu.org/packages/")
                         ("marmalade" . "https://marmalade-repo.org/packages/")
                         ("melpa" . "http://melpa.org/packages/")
                         ("melpa-stable" . "https://stable.melpa.org/packages/")))

;; Refreshing!
(package-initialize)

;; Some important packages
(dolist (pkg '(haskell-mode
               scala-mode
               drag-stuff
               powerline
               ensime
               fill-column-indicator))
  (require pkg))

;; Let's get naked
(show-paren-mode t)
(scroll-bar-mode 0)
(blink-cursor-mode 0)
(tool-bar-mode 0)
(menu-bar-mode 0)

(setq-default inhibit-scratch-message nil
              initial-scratch-message ""
              indent-tabs-mode nil
              tab-width 4
              tab-always-indent (quote complete))
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
      version-control t)

(electric-indent-mode t)
(electric-pair-mode t)
(electric-layout-mode t)
(drag-stuff-mode t)
(powerline-default-theme)

(defalias 'yes-or-no-p 'y-or-n-p) 

(use-package ensime
  :pin melpa-stable
  :init
  (setq ensime-startup-snapshot-notification nil))


(use-package flycheck
  :commands global-flycheck-mode
  :diminish " fc"
  :init
  (add-hook 'after-init-hook #'global-flycheck-mode)
  :config
  (use-package flycheck-pos-tip
    :config
    (setq flycheck-pos-tip-timeout 7
          flycheck-display-errors-delay 0.5)
    (flycheck-pos-tip-mode +1))
  (define-fringe-bitmap 'flycheck-fringe-bitmap-double-arrow
    [0 0 0 0 0 256 384 448 480 496 480 448 384 256 0 0 0 0 0]
    ))

(use-package projectile
  :demand
  :init
  (setq projectile-use-git-grep t)
  :config
  (projectile-global-mode t)
  :bind
  (("C-c f" . projectile-find-file)
   ("C-c C-f" . projectile-grep)))

(use-package undo-tree
  :diminish undo-tree-mode
  :config (global-undo-tree-mode)
  :bind ("C-?" . undo-tree-visualize))

(use-package ido
  :init
  (ido-mode t)
  :config
  (setq ido-auto-merge-work-directories-length -1) ;; this keeps ido from searching globally
  (define-key ido-file-dir-completion-map (kbd "C-c C-s")
    (lambda()
      (interactive)
      (ido-initiate-auto-merge (current-buffer))))
  (use-package flx-ido
    :init
    (flx-ido-mode t))
  (use-package ido-vertical-mode
    :init
    (ido-vertical-mode 1)
    :config
    (setq ido-enable-flex-matching t
          ido-show-dot-for-dired nil
          ido-enable-dot-prefix t)))

(use-package nlinum
  :commands nlinum-mode
  :init (add-hook 'prog-mode-hook 'nlinum-mode)
  :config
  (setq nlinum-format "%4d "))

(use-package hl-line
  :after nlinum
  :commands hl-line-mode
  :init
  (add-hook 'nlinum-mode-hook #'hl-line-mode))

;; Allows highlighting the current symbol
(use-package highlight-symbol
  :diminish highlight-symbol-mode
  :commands highlight-symbol
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
  :commands magit-status magit-blame
  :init (setq magit-revert-buffers nil
              magit-auto-revert-mode nil
              magit-las-seen-setup-instruction "1.4.0")
  :bind (("C-c C-g s" . magit-status)
         ("C-c C-g b" . magit-blame)))

(use-package company
  :diminish company-mode
  :commands company-mode
  :init (setq company-dabbrev-ignore-case nil
              company-dabbrev-code-ignore-case nil
              company-dabbrev-downcase nil
              company-idle-delay 0
              company-minimum-prefix-length 4))

(use-package yasnippet
  :diminish yas-minor-mode
  :commands yas-minor-mode
  :config (yas-reload-all))

(use-package etags-select
  :commands etags-select-find-tag)

(use-package ace-jump-mode
  :commands ace-jump-mode
  :init (define-key global-map (kbd "C-c SPC") 'ace-jump-mode))

;; Rust Support

(use-package rust-mode
  :mode "\\.rs\\'"
  :commands rust-mode
  :config
  (setq rust-format-on-save t)
  (use-package flycheck-rust
    :after flycheck
    :commands flycheck-rust-setup
    :init
    (add-hook 'flycheck-mode-hook #'flycheck-rust-setup)))

(use-package racer
  :commands racer-mode
  :diminish racer-mode
  :init
  (add-hook 'rust-mode-hook 'racer-mode)
  (add-hook 'rust-mode-hook 'eldoc-mode)
  :bind (:map rust-mode-map
              ("M-." . racer-find-definition))
  :config
  (use-package company-racer
    :config
    (add-to-list 'company-backends 'company-racer)
    (setq company-tooltip-align-annotations t)))

(use-package cargo
  :commands cargo-minor-mode
  :diminish cargo-minor-mode
  :init
  (add-hook 'rust-mode-hook 'cargo-minor-mode))

(use-package toml-mode
  :mode (("\\.toml\\'" . toml-mode)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;; This is going to save lives
(defun contextual-backspace ()
  "Hungry whitespace or delete work depending on context."
  (interactive)
  (if (looking-back "[[:space:]\n]\\{2,\\}" (- (point) 2))
      (while (looking-back "[[:space:]\n]" (- (point) 1))
        (delete-char -1))
    (cond
     ((and (boundp 'smart-parens-strict-mode)
           smartparens-strict-mode)
      (sp-backward-kill-work 1))
     ((and (boundp 'subword-mode)
           subword-mode)
      (subword-backward-kill 1))
     (t
      (backward-kill-word 1)))))

(global-set-key (kbd "C-<backspace>") 'contextual-backspace)

(defun ensime-edit-definition-with-fallback ()
  "Variant of `ensime-edit-definition' with ctags if ENSIME is not available."
  (interactive)
  (unless (and (ensime-connection-or-nil)
               (ensime-edit-definition))
    (projectile-find-tag)))

(bind-key "M-." 'ensime-edit-definition-with-fallback ensime-mode-map)
(global-set-key (kbd "M-.") 'projectile-find-tag)
(global-set-key (kbd "M-,") 'pop-tag-mark)

(defun scala-mode-newline-comments ()
  "Custom newline appropriate for `scala-mode'."
  ;; shouldn't this be in a post-insert hook?
  (interactive)
  (newline-and-indent)
  (scala-indent:insert-asterisk-on-multiline-comment))

(bind-key "RET" 'scala-mode-newline-comments scala-mode-map)

(add-hook 'prog-mode-hook
          (lambda ()
            (yas-minor-mode)
            (hs-minor-mode)
            (subword-mode)))

(require 'cl-lib)
(require 'color)

(add-hook 'js2-mode-hook (lambda ()
                           (flymake-jshint-load)
                           (local-set-key (kbd "C-c f") 'jstidy)))

(add-hook 'hs-minor-mode-hook (lambda ()
                                (local-set-key (kbd "C-c C-h") 'hs-hide-block)
                                (local-set-key (kbd "C-c C-s") 'hs-show-block)
                                (local-set-key (kbd "C-c C-S-h") 'hs-hide-all)
                                (local-set-key (kbd "C-c C-S-s") 'hs-show-all)))

(defun jstidy ()
  "Run js-beautify on the current region or buffer."
  (interactive)
  (save-excursion
    (unless mark-active (mark-defun))
    (shell-command-on-region (point) (mark) "js-beautify --good-stuff -f -" nil t)))

(add-to-list 'auto-mode-alist '("\\.js$" . js2-mode))

;; Clojure Config
;;;; Cider config
(add-hook 'cider-mode-hook 'cider-turn-on-eldoc-mode)
(setq nrepl-hide-special-buffers t)

(add-hook 'scala-mode-hook
          (lambda ()
            (company-mode)
            (ensime-mode)))

(setq inferior-js-program-command "node --interactive")
;; Time for some haskell
(autoload 'ghc-init "ghc" nil t)
(add-hook 'haskell-mode-hook (lambda () (ghc-init) (flymake-mode)))

(setq-default fill-column 120)

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
    ("0c29db826418061b40564e3351194a3d4a125d182c6ee5178c237a7364f0ff12" "e26780280b5248eb9b2d02a237d9941956fc94972443b0f7aeec12b5c15db9f3" default)))
 '(ensime-log-events t t)
 '(flx-ido-mode t)
 '(haskell-mode-hook
   (quote
    (turn-on-haskell-decl-scan turn-on-haskell-doc turn-on-haskell-indentation)))
 '(js2-basic-offset 2)
 '(package-selected-packages
   (quote
    (flycheck-pos-tip rainbow-delimiters flycheck hl-line+ nlinum highlight-symbol projectile ido-vertical-mode flx-ido toml-mode cargo racer rust-mode darkroom ace-jump-mode markdown-mode sublime-themes ensime use-package drag-stuff fill-column-indicator haskell-mode powerline scala-mode)))
 '(projectile-global-mode t)
 '(projectile-tags-backend (quote ggtags))
 '(projectile-use-git-grep t)
 '(sbt:ansi-support t))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:inherit nil :stipple nil :background "#161A1F" :foreground "#DEDEDE" :inverse-video nil :box nil :strike-through nil :overline nil :underline nil :slant normal :weight normal :height 140 :width normal :foundry "unknown" :family "Consolas"))))
 '(ensime-errline-highlight ((t (:inherit flymake-errline))))
 '(hl-line ((t (:inherit highlight :background "#151515" :underline nil))))
 '(sbt:error ((t (:inherit error)))))
(put 'downcase-region 'disabled nil)

;; Load Golang Config
;;(load-file "./.emacs.d/golang.el")
