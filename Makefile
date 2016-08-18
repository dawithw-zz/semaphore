IDENT=-DDDB -DDIAGNOSTIC -DKTRACE -DKMEMSTATS -DPTRACE -DCRYPTO -DSYSVMSG -DSYSVSEM -DSYSVSHM -DUVM_SWAP_ENCRYPT -DCOMPAT_43 -DLKM -DFFS -DFFS_SOFTUPDATES -DUFS_DIRHASH -DQUOTA -DEXT2FS -DMFS -DXFS -DTCP_SACK -DTCP_ECN -DTCP_SIGNATURE -DNFSCLIENT -DNFSSERVER -DCD9660 -DMSDOSFS -DFDESC -DFIFO -DKERNFS -DPORTAL -DPROCFS -DNULLFS -DUMAPFS -DUNION -DINET -DALTQ -DINET6 -DIPSEC -DPPP_BSDCOMP -DPPP_DEFLATE -DBOOT_CONFIG -DI386_CPU -DI486_CPU -DI586_CPU -DI686_CPU -DGPL_MATH_EMULATE -DUSER_PCICONF -DUSER_LDT -DAPERTURE -DCOMPAT_SVR4 -DCOMPAT_IBCS2 -DCOMPAT_LINUX -DCOMPAT_FREEBSD -DCOMPAT_BSDOS -DCOMPAT_AOUT -DPCIVERBOSE -DEISAVERBOSE -DUSBVERBOSE -DWSDISPLAY_COMPAT_USL -DWSDISPLAY_COMPAT_RAWKBD -DWSDISPLAY_DEFAULTSCREENS="6" -DWSDISPLAY_COMPAT_PCVT -DPCIAGP
PARAM=-DMAXUSERS=32
S!=	echo `/bin/pwd`/../../../..
#	$OpenBSD: Makefile.i386,v 1.39 2003/11/20 08:38:52 espie Exp $
#	$NetBSD: Makefile.i386,v 1.67 1996/05/11 16:12:11 mycroft Exp $

# Makefile for OpenBSD
#
# This makefile is constructed from a machine description:
#	config machineid
# Most changes should be made in the machine description
#	/sys/arch/i386/conf/``machineid''
# after which you should do
#	config machineid
# Machine generic makefile changes should be made in
#	/sys/arch/i386/conf/Makefile.i386
# after which config should be rerun for all machines of that type.
#
# N.B.: NO DEPENDENCIES ON FOLLOWING FLAGS ARE VISIBLE TO MAKEFILE
#	IF YOU CHANGE THE DEFINITION OF ANY OF THESE RECOMPILE EVERYTHING
#
# -DTRACE	compile in kernel tracing hooks
# -DQUOTA	compile in file system quotas

# DEBUG is set to -g if debugging.
# PROF is set to -pg if profiling.

.include <bsd.own.mk>

MKDEP?=	mkdep
SIZE?=	size
STRIP?=	strip

# source tree is located via $S relative to the compilation directory
.ifndef S
S!=	cd ../../../..; pwd
.endif
I386=	$S/arch/i386

INCLUDES=	-nostdinc -I. -I$S/arch -I$S
CPPFLAGS=	${INCLUDES} ${IDENT} -D_KERNEL -Di386
CDIAGFLAGS=	-Werror -Wall -Wstrict-prototypes -Wmissing-prototypes \
		-Wno-uninitialized -Wno-format -Wno-main

.if !${IDENT:M-DI386_CPU}
CMACHFLAGS=	-march=i486
.else
CMACHFLAGS=
.endif
.if ${IDENT:M-DNO_PROPOLICE}
CMACHFLAGS+=	-fno-stack-protector
.endif
CMACHFLAGS+=	-fno-builtin-printf -fno-builtin-log

COPTS?=		-O2
CFLAGS=		${DEBUG} ${CDIAGFLAGS} ${CMACHFLAGS} ${COPTS} ${PIPE}
AFLAGS=		-x assembler-with-cpp -traditional-cpp -D_LOCORE
LINKFLAGS=	-Ttext 0xD0100120 -e start -N
STRIPFLAGS=	-g -X -x

HOSTCC= ${CC}
HOSTED_CPPFLAGS=${CPPFLAGS:S/^-nostdinc$//}
HOSTED_CFLAGS=	${CFLAGS}

### find out what to use for libkern
.include "$S/lib/libkern/Makefile.inc"
.ifndef PROF
LIBKERN=	${KERNLIB}
.else
LIBKERN=	${KERNLIB_PROF}
.endif

### find out what to use for libcompat
.include "$S/compat/common/Makefile.inc"
.ifndef PROF
LIBCOMPAT=	${COMPATLIB}
.else
LIBCOMPAT=	${COMPATLIB_PROF}
.endif

# compile rules: rules are named ${TYPE}_${SUFFIX}${CONFIG_DEP}
# where TYPE is NORMAL, DRIVER, or PROFILE; SUFFIX is the file suffix,
# capitalized (e.g. C for a .c file), and CONFIG_DEP is _C if the file
# is marked as config-dependent.

NORMAL_C=	${CC} ${CFLAGS} ${CPPFLAGS} ${PROF} -c $<
NORMAL_C_C=	${CC} ${CFLAGS} ${CPPFLAGS} ${PROF} ${PARAM} -c $<

DRIVER_C=	${CC} ${CFLAGS} ${CPPFLAGS} ${PROF} -c $<
DRIVER_C_C=	${CC} ${CFLAGS} ${CPPFLAGS} ${PROF} ${PARAM} -c $<

NORMAL_S=	${CC} ${AFLAGS} ${CPPFLAGS} -c $<
NORMAL_S_C=	${CC} ${AFLAGS} ${CPPFLAGS} ${PARAM} -c $<

HOSTED_C=	${HOSTCC} ${HOSTED_CFLAGS} ${HOSTED_CPPFLAGS} -c $<

OBJS=	cop4600.o \
	smc93cx6.o pcdisplay_subr.o pcdisplay_chars.o vga.o vga_subr.o \
	mii_bitbang.o wdc.o aic7xxx.o aic7xxx_openbsd.o aic7xxx_seeprom.o \
	aic6360.o dpt.o adv.o adw.o bha.o gdt_common.o twe.o cac.o ami.o \
	isp.o isp_openbsd.o mpt.o mpt_debug.o mpt_openbsd.o uha.o \
	ncr53c9x.o siop_common.o siop.o elink3.o lemac.o if_wi.o \
	if_wi_hostap.o an.o am7990.o xl.o fxp.o mtd8xx.o rtl81x9.o dc.o \
	smc91cxx.o ne2000.o dl10019.o ax88190.o pckbc.o opl.o oplinstrs.o \
	ac97.o cy.o lpt.o iha.o trm.o nslm7x.o uhci.o ohci.o radio.o \
	ksyms.o pf.o pf_norm.o pf_ioctl.o pf_table.o pf_osfp.o pf_if.o \
	if_pflog.o if_pfsync.o bio.o altq_subr.o altq_red.o altq_cbq.o \
	altq_rmclass.o altq_hfsc.o altq_priq.o db_access.o db_aout.o \
	db_break.o db_command.o db_elf.o db_examine.o db_expr.o \
	db_input.o db_lex.o db_output.o db_print.o db_run.o db_sym.o \
	db_trap.o db_variables.o db_watch.o db_write_cmd.o db_usrreq.o \
	db_hangman.o auconv.o audio.o ccd.o pdq.o pdq_ifsubr.o dp8390.o \
	rtl80x9.o tea5757.o midi.o midisyn.o mulaw.o sequencer.o \
	systrace.o vnd.o rnd.o cd9660_bmap.o cd9660_lookup.o \
	cd9660_node.o cd9660_rrip.o cd9660_util.o cd9660_vfsops.o \
	cd9660_vnops.o exec_aout.o exec_conf.o exec_ecoff.o exec_elf32.o \
	exec_elf64.o exec_script.o exec_subr.o init_main.o init_sysent.o \
	kern_acct.o kern_clock.o kern_descrip.o kern_event.o kern_exec.o \
	kern_exit.o kern_fork.o kern_kthread.o kern_ktrace.o kern_lock.o \
	kern_lkm.o kern_malloc.o kern_rwlock.o kern_physio.o kern_proc.o \
	kern_prot.o kern_resource.o kern_sig.o kern_subr.o kern_sysctl.o \
	kern_synch.o kern_time.o kern_timeout.o kern_watchdog.o \
	kern_xxx.o subr_autoconf.o subr_disk.o subr_extent.o subr_log.o \
	subr_pool.o subr_prf.o subr_prof.o subr_userconf.o subr_xxx.o \
	sys_generic.o sys_pipe.o sys_process.o sys_socket.o sysv_ipc.o \
	sysv_msg.o sysv_sem.o sysv_shm.o tty.o tty_conf.o tty_pty.o \
	tty_subr.o tty_tb.o tty_tty.o uipc_domain.o uipc_mbuf.o \
	uipc_mbuf2.o uipc_proto.o uipc_socket.o uipc_socket2.o \
	uipc_syscalls.o uipc_usrreq.o vfs_bio.o vfs_cache.o vfs_cluster.o \
	vfs_conf.o vfs_default.o vfs_init.o vfs_lockf.o vfs_lookup.o \
	vfs_subr.o vfs_sync.o vfs_syscalls.o vfs_vnops.o vnode_if.o \
	dead_vnops.o layer_subr.o layer_vfsops.o layer_vnops.o \
	fdesc_vfsops.o fdesc_vnops.o fifo_vnops.o kernfs_vfsops.o \
	kernfs_vnops.o null_vfsops.o null_vnops.o portal_vfsops.o \
	portal_vnops.o procfs_cmdline.o procfs_ctl.o procfs_fpregs.o \
	procfs_linux.o procfs_mem.o procfs_note.o procfs_regs.o \
	procfs_status.o procfs_subr.o procfs_vfsops.o procfs_vnops.o \
	spec_vnops.o umap_subr.o umap_vfsops.o umap_vnops.o union_subr.o \
	union_vfsops.o union_vnops.o msdosfs_conv.o msdosfs_denode.o \
	msdosfs_fat.o msdosfs_lookup.o msdosfs_vfsops.o msdosfs_vnops.o \
	bpf.o bpf_filter.o if.o if_ethersubr.o if_fddisubr.o \
	if_spppsubr.o if_loop.o if_media.o if_sl.o if_ppp.o ppp_tty.o \
	bsd-comp.o ppp-deflate.o zlib.o if_tun.o if_bridge.o bridgestp.o \
	if_vlan.o radix.o raw_cb.o raw_usrreq.o route.o rtsock.o \
	slcompress.o if_enc.o if_gre.o if_ether.o in4_cksum.o igmp.o in.o \
	in_pcb.o in_proto.o ip_icmp.o ip_id.o ip_input.o ip_output.o \
	raw_ip.o tcp_debug.o tcp_input.o tcp_output.o tcp_subr.o \
	tcp_timer.o tcp_usrreq.o udp_usrreq.o ip_gre.o ip_ipsp.o ip_spd.o \
	ip_ipip.o ip_ether.o ipsec_input.o ipsec_output.o ip_esp.o \
	ip_ah.o ip_carp.o ip_ipcomp.o rijndael.o rmd160.o sha1.o sha2.o \
	blf.o cast.o skipjack.o ecb_enc.o set_key.o ecb3_enc.o crypto.o \
	cryptodev.o criov.o cryptosoft.o xform.o deflate.o arc4.o \
	krpc_subr.o nfs_bio.o nfs_boot.o nfs_node.o nfs_serv.o \
	nfs_socket.o nfs_srvcache.o nfs_subs.o nfs_syscalls.o \
	nfs_vfsops.o nfs_vnops.o ffs_alloc.o ffs_balloc.o ffs_inode.o \
	ffs_subr.o ffs_softdep_stub.o ffs_tables.o ffs_vfsops.o \
	ffs_vnops.o ffs_softdep.o mfs_vfsops.o mfs_vnops.o ufs_bmap.o \
	ufs_dirhash.o ufs_extattr.o ufs_ihash.o ufs_inode.o ufs_lookup.o \
	ufs_quota.o ufs_quota_stub.o ufs_vfsops.o ufs_vnops.o \
	ext2fs_alloc.o ext2fs_balloc.o ext2fs_bmap.o ext2fs_bswap.o \
	ext2fs_inode.o ext2fs_lookup.o ext2fs_readwrite.o ext2fs_subr.o \
	ext2fs_vfsops.o ext2fs_vnops.o xfs_common-bsd.o xfs_deb.o \
	xfs_dev-bsd.o xfs_dev-common.o xfs_message.o xfs_node.o \
	xfs_node-bsd.o xfs_syscalls-common.o xfs_vfsops-bsd.o \
	xfs_vfsops-common.o xfs_vfsops-openbsd.o xfs_vnodeops-bsd.o \
	xfs_vnodeops-common.o uvm_amap.o uvm_anon.o uvm_aobj.o \
	uvm_device.o uvm_fault.o uvm_glue.o uvm_init.o uvm_io.o uvm_km.o \
	uvm_map.o uvm_meter.o uvm_mmap.o uvm_page.o uvm_pager.o \
	uvm_pdaemon.o uvm_pglist.o uvm_stat.o uvm_swap.o \
	uvm_swap_encrypt.o uvm_unix.o uvm_user.o uvm_vnode.o if_gif.o \
	ip_ecn.o in_gif.o in6_gif.o in6_pcb.o in6.o in6_ifattach.o \
	in6_cksum.o in6_src.o in6_proto.o dest6.o frag6.o icmp6.o \
	ip6_id.o ip6_input.o ip6_forward.o ip6_mroute.o ip6_output.o \
	route6.o mld6.o nd6.o nd6_nbr.o nd6_rtr.o raw_ip6.o udp6_output.o \
	pfkey.o pfkeyv2.o pfkeyv2_parsemessage.o pfkeyv2_convert.o \
	autoconf.o conf.o db_disasm.o db_interface.o db_memrw.o \
	db_trace.o db_magic.o disksubr.o est.o gdt.o in_cksum.o machdep.o \
	longrun.o mem.o i686_mem.o k6_mem.o microtime.o p4tcc.o pmap.o \
	process_machdep.o procfs_machdep.o random.o sys_machdep.o trap.o \
	vm_machdep.o dkcsum.o cons.o cninit.o wscons_machdep.o mii.o \
	mii_physubr.o ukphy_subr.o nsphy.o nsphyter.o qsphy.o inphy.o \
	iophy.o eephy.o exphy.o rlphy.o lxtphy.o mtdphy.o icsphy.o \
	sqphy.o tqphy.o ukphy.o dcphy.o bmtphy.o brgphy.o xmphy.o amphy.o \
	acphy.o nsgphy.o urlphy.o scsi_base.o scsi_ioctl.o scsiconf.o \
	atapi_base.o cd.o cd_scsi.o cd_atapi.o ch.o sd.o sd_atapi.o \
	sd_scsi.o st.o ss.o ss_mustek.o ss_scanjet.o uk.o iop.o ioprbs.o \
	atapiscsi.o wd.o ata_wdc.o ata.o mainbus.o pci.o pci_map.o \
	pci_quirks.o pci_subr.o vga_pci.o cy82c693.o ahc_pci.o dpt_pci.o \
	adv_pci.o advlib.o advmcode.o adw_pci.o adwlib.o adwmcode.o \
	bha_pci.o twe_pci.o ami_pci.o iop_pci.o eap.o eso.o opl_eso.o \
	auich.o emuxki.o autri.o cs4280.o cs4281.o maestro.o esa.o yds.o \
	opl_yds.o fms.o fmsradio.o auvia.o gdt_pci.o aac_pci.o aac.o \
	cac_pci.o isp_pci.o mpt_pci.o if_de.o if_ep_pci.o if_fpa.o \
	if_le_pci.o siop_pci_common.o siop_pci.o neo.o pciide.o ppb.o \
	cy_pci.o if_lmc.o if_lmc_common.o if_lmc_media.o if_lmc_obsd.o \
	if_mtd_pci.o if_rl_pci.o if_vr.o if_tl.o if_txp.o sv.o \
	bktr_audio.o bktr_card.o bktr_core.o bktr_os.o bktr_tuner.o \
	if_xl_pci.o if_fxp_pci.o if_em.o if_em_hw.o if_dc_pci.o if_tx.o \
	if_ti.o if_ne_pci.o lofn.o hifn7751.o nofn.o ubsec.o safe.o \
	if_wb.o if_sf.o if_sis.o if_ste.o uhci_pci.o ohci_pci.o pccbb.o \
	if_sk.o puc.o pucdata.o if_wi_pci.o if_an_pci.o cmpci.o iha_pci.o \
	trm_pci.o pcscp.o if_nge.o if_bge.o if_stge.o viaenv.o if_bce.o \
	pci_machdep.o agp_machdep.o agp_ali.o agp_amd.o agp_i810.o \
	agp_intel.o agp_sis.o agp_via.o pciide_machdep.o \
	pcic_pci_machdep.o pchb.o elan520.o geodesc.o pcib.o hme.o \
	if_hme_pci.o isa.o isadma.o ast.o cy_isa.o pckbc_isa.o vga_isa.o \
	pcdisplay.o bha_isa.o aic_isa.o aha.o seagate.o uha_isa.o wds.o \
	opti.o wdc_isa.o if_lc_isa.o if_ne_isa.o if_we.o elink.o if_ec.o \
	if_eg.o if_el.o if_ep_isa.o if_ie.o if_ex.o if_le.o if_le_isa.o \
	mpu401.o mpu_isa.o sbdsp.o sb.o sb_isa.o opl_sb.o pas.o ad1848.o \
	ics2101.o pss.o wss.o wss_isa.o ess.o opl_ess.o gus.o gus_isa.o \
	pcppi.o midi_pcppi.o lpt_isa.o lm_isa.o nsclpcsio_isa.o it.o \
	isa_machdep.o clock.o clock_subr.o npx.o div_small.o errors.o \
	fpu_arith.o fpu_aux.o fpu_entry.o fpu_etc.o fpu_trig.o \
	get_address.o load_store.o poly_2xm1.o poly_atan.o poly_div.o \
	poly_l2.o poly_mul64.o poly_sin.o poly_tan.o polynomial.o \
	reg_add_sub.o reg_compare.o reg_constant.o reg_div.o reg_ld_str.o \
	reg_mul.o reg_norm.o reg_round.o reg_u_add.o reg_u_div.o \
	reg_u_mul.o reg_u_sub.o wm_shrx.o wm_sqrt.o pccom.o lms.o mms.o \
	wsdisplay.o wsdisplay_compat_usl.o wsemulconf.o wsemul_vt100.o \
	wsemul_vt100_subr.o wsemul_vt100_chars.o wsemul_vt100_keys.o \
	wsevent.o wskbd.o wskbdutil.o wsmouse.o wsmux.o pckbd.o \
	wskbdmap_mfii.o psm.o psm_intelli.o fdc.o fd.o ahc_isa.o pctr.o \
	mtrr.o eisa.o aha1742.o ahc_eisa.o dpt_eisa.o uha_eisa.o \
	cac_eisa.o if_ep_eisa.o if_fea.o eisa_machdep.o isapnp.o \
	isapnpdebug.o isapnpres.o mpu_isapnp.o wdc_isapnp.o aic_isapnp.o \
	sb_isapnp.o wss_isapnp.o ess_isapnp.o if_an_isapnp.o \
	if_le_isapnp.o if_ep_isapnp.o if_ef_isapnp.o if_ne_isapnp.o ym.o \
	ym_isapnp.o isapnp_machdep.o joy.o joy_isapnp.o compat_aout.o \
	svr4_errno.o svr4_exec.o svr4_fcntl.o svr4_filio.o svr4_ioctl.o \
	svr4_ipc.o svr4_jioctl.o svr4_misc.o svr4_net.o svr4_signal.o \
	svr4_socket.o svr4_sockio.o svr4_stat.o svr4_stream.o \
	svr4_sysent.o svr4_termios.o svr4_ttold.o svr4_machdep.o \
	ibcs2_errno.o ibcs2_exec.o ibcs2_fcntl.o ibcs2_ioctl.o \
	ibcs2_ipc.o ibcs2_misc.o ibcs2_signal.o ibcs2_socksys.o \
	ibcs2_stat.o ibcs2_sysent.o linux_blkio.o linux_cdrom.o \
	linux_error.o linux_exec.o linux_fdio.o linux_file.o \
	linux_file64.o linux_getcwd.o linux_hdio.o linux_ioctl.o \
	linux_ipc.o linux_misc.o linux_mount.o linux_resource.o \
	linux_sched.o linux_signal.o linux_socket.o linux_sysent.o \
	linux_termios.o linux_dummy.o linux_machdep.o bsdos_exec.o \
	bsdos_ioctl.o bsdos_sysent.o freebsd_exec.o freebsd_file.o \
	freebsd_ioctl.o freebsd_misc.o freebsd_ptrace.o freebsd_signal.o \
	freebsd_sysent.o freebsd_machdep.o ossaudio.o bios.o apm.o \
	apmcall.o pcibios.o pci_intr_fixup.o pci_bus_fixup.o \
	pci_addr_fixup.o opti82c558.o opti82c700.o piix.o sis85c503.o \
	via82c586.o via8231.o amd756.o ali1543.o cardslot.o cardbus.o \
	cardbus_map.o cardbus_exrom.o rbus.o if_xl_cardbus.o \
	if_dc_cardbus.o if_fxp_cardbus.o if_rl_cardbus.o rbus_machdep.o \
	i82365.o i82365_isa.o i82365_pci.o i82365_isapnp.o \
	i82365_isasubr.o tcic2.o tcic2_isa.o com_puc.o lpt_puc.o pcmcia.o \
	pcmcia_cis.o pcmcia_cis_quirks.o if_ep_pcmcia.o if_ne_pcmcia.o \
	aic_pcmcia.o com_pcmcia.o wdc_pcmcia.o if_sm_pcmcia.o if_xe.o \
	if_wi_pcmcia.o if_ray.o if_an_pcmcia.o usb.o usbdi.o usbdi_util.o \
	usb_mem.o usb_subr.o usb_quirks.o uhub.o uaudio.o ucom.o ugen.o \
	hid.o uhidev.o uhid.o ukbd.o ukbdmap.o ums.o ulpt.o umass.o \
	umass_quirks.o umass_scsi.o urio.o uvisor.o if_aue.o if_cue.o \
	if_kue.o if_upl.o if_url.o umodem.o uftdi.o uplcom.o ubsa.o \
	uscanner.o usscanner.o if_wi_usb.o

CFILES=	$S/kern/cop4600.c \
	$S/dev/ic/smc93cx6.c $S/dev/ic/pcdisplay_subr.c \
	$S/dev/ic/pcdisplay_chars.c $S/dev/ic/vga.c $S/dev/ic/vga_subr.c \
	$S/dev/mii/mii_bitbang.c $S/dev/ic/wdc.c $S/dev/ic/aic7xxx.c \
	$S/dev/ic/aic7xxx_openbsd.c $S/dev/ic/aic7xxx_seeprom.c \
	$S/dev/ic/aic6360.c $S/dev/ic/dpt.c $S/dev/ic/adv.c \
	$S/dev/ic/adw.c $S/dev/ic/bha.c $S/dev/ic/gdt_common.c \
	$S/dev/ic/twe.c $S/dev/ic/cac.c $S/dev/ic/ami.c $S/dev/ic/isp.c \
	$S/dev/ic/isp_openbsd.c $S/dev/ic/mpt.c $S/dev/ic/mpt_debug.c \
	$S/dev/ic/mpt_openbsd.c $S/dev/ic/uha.c $S/dev/ic/ncr53c9x.c \
	$S/dev/ic/siop_common.c $S/dev/ic/siop.c $S/dev/ic/elink3.c \
	$S/dev/ic/lemac.c $S/dev/ic/if_wi.c $S/dev/ic/if_wi_hostap.c \
	$S/dev/ic/an.c $S/dev/ic/am7990.c $S/dev/ic/xl.c $S/dev/ic/fxp.c \
	$S/dev/ic/mtd8xx.c $S/dev/ic/rtl81x9.c $S/dev/ic/dc.c \
	$S/dev/ic/smc91cxx.c $S/dev/ic/ne2000.c $S/dev/ic/dl10019.c \
	$S/dev/ic/ax88190.c $S/dev/ic/pckbc.c $S/dev/ic/opl.c \
	$S/dev/ic/oplinstrs.c $S/dev/ic/ac97.c $S/dev/ic/cy.c \
	$S/dev/ic/lpt.c $S/dev/ic/iha.c $S/dev/ic/trm.c \
	$S/dev/ic/nslm7x.c $S/dev/usb/uhci.c $S/dev/usb/ohci.c \
	$S/dev/radio.c $S/dev/ksyms.c $S/net/pf.c $S/net/pf_norm.c \
	$S/net/pf_ioctl.c $S/net/pf_table.c $S/net/pf_osfp.c \
	$S/net/pf_if.c $S/net/if_pflog.c $S/net/if_pfsync.c $S/dev/bio.c \
	$S/altq/altq_subr.c $S/altq/altq_red.c $S/altq/altq_cbq.c \
	$S/altq/altq_rmclass.c $S/altq/altq_hfsc.c $S/altq/altq_priq.c \
	$S/ddb/db_access.c $S/ddb/db_aout.c $S/ddb/db_break.c \
	$S/ddb/db_command.c $S/ddb/db_elf.c $S/ddb/db_examine.c \
	$S/ddb/db_expr.c $S/ddb/db_input.c $S/ddb/db_lex.c \
	$S/ddb/db_output.c $S/ddb/db_print.c $S/ddb/db_run.c \
	$S/ddb/db_sym.c $S/ddb/db_trap.c $S/ddb/db_variables.c \
	$S/ddb/db_watch.c $S/ddb/db_write_cmd.c $S/ddb/db_usrreq.c \
	$S/ddb/db_hangman.c $S/dev/auconv.c $S/dev/audio.c $S/dev/ccd.c \
	$S/dev/ic/pdq.c $S/dev/ic/pdq_ifsubr.c $S/dev/ic/dp8390.c \
	$S/dev/ic/rtl80x9.c $S/dev/ic/tea5757.c $S/dev/midi.c \
	$S/dev/midisyn.c $S/dev/mulaw.c $S/dev/sequencer.c \
	$S/dev/systrace.c $S/dev/vnd.c $S/dev/rnd.c \
	$S/isofs/cd9660/cd9660_bmap.c $S/isofs/cd9660/cd9660_lookup.c \
	$S/isofs/cd9660/cd9660_node.c $S/isofs/cd9660/cd9660_rrip.c \
	$S/isofs/cd9660/cd9660_util.c $S/isofs/cd9660/cd9660_vfsops.c \
	$S/isofs/cd9660/cd9660_vnops.c $S/kern/exec_aout.c \
	$S/kern/exec_conf.c $S/kern/exec_ecoff.c $S/kern/exec_elf32.c \
	$S/kern/exec_elf64.c $S/kern/exec_script.c $S/kern/exec_subr.c \
	$S/kern/init_main.c $S/kern/init_sysent.c $S/kern/kern_acct.c \
	$S/kern/kern_clock.c $S/kern/kern_descrip.c $S/kern/kern_event.c \
	$S/kern/kern_exec.c $S/kern/kern_exit.c $S/kern/kern_fork.c \
	$S/kern/kern_kthread.c $S/kern/kern_ktrace.c $S/kern/kern_lock.c \
	$S/kern/kern_lkm.c $S/kern/kern_malloc.c $S/kern/kern_rwlock.c \
	$S/kern/kern_physio.c $S/kern/kern_proc.c $S/kern/kern_prot.c \
	$S/kern/kern_resource.c $S/kern/kern_sig.c $S/kern/kern_subr.c \
	$S/kern/kern_sysctl.c $S/kern/kern_synch.c $S/kern/kern_time.c \
	$S/kern/kern_timeout.c $S/kern/kern_watchdog.c $S/kern/kern_xxx.c \
	$S/kern/subr_autoconf.c $S/kern/subr_disk.c $S/kern/subr_extent.c \
	$S/kern/subr_log.c $S/kern/subr_pool.c $S/kern/subr_prf.c \
	$S/kern/subr_prof.c $S/kern/subr_userconf.c $S/kern/subr_xxx.c \
	$S/kern/sys_generic.c $S/kern/sys_pipe.c $S/kern/sys_process.c \
	$S/kern/sys_socket.c $S/kern/sysv_ipc.c $S/kern/sysv_msg.c \
	$S/kern/sysv_sem.c $S/kern/sysv_shm.c $S/kern/tty.c \
	$S/kern/tty_conf.c $S/kern/tty_pty.c $S/kern/tty_subr.c \
	$S/kern/tty_tb.c $S/kern/tty_tty.c $S/kern/uipc_domain.c \
	$S/kern/uipc_mbuf.c $S/kern/uipc_mbuf2.c $S/kern/uipc_proto.c \
	$S/kern/uipc_socket.c $S/kern/uipc_socket2.c \
	$S/kern/uipc_syscalls.c $S/kern/uipc_usrreq.c $S/kern/vfs_bio.c \
	$S/kern/vfs_cache.c $S/kern/vfs_cluster.c $S/kern/vfs_conf.c \
	$S/kern/vfs_default.c $S/kern/vfs_init.c $S/kern/vfs_lockf.c \
	$S/kern/vfs_lookup.c $S/kern/vfs_subr.c $S/kern/vfs_sync.c \
	$S/kern/vfs_syscalls.c $S/kern/vfs_vnops.c $S/kern/vnode_if.c \
	$S/miscfs/deadfs/dead_vnops.c $S/miscfs/genfs/layer_subr.c \
	$S/miscfs/genfs/layer_vfsops.c $S/miscfs/genfs/layer_vnops.c \
	$S/miscfs/fdesc/fdesc_vfsops.c $S/miscfs/fdesc/fdesc_vnops.c \
	$S/miscfs/fifofs/fifo_vnops.c $S/miscfs/kernfs/kernfs_vfsops.c \
	$S/miscfs/kernfs/kernfs_vnops.c $S/miscfs/nullfs/null_vfsops.c \
	$S/miscfs/nullfs/null_vnops.c $S/miscfs/portal/portal_vfsops.c \
	$S/miscfs/portal/portal_vnops.c $S/miscfs/procfs/procfs_cmdline.c \
	$S/miscfs/procfs/procfs_ctl.c $S/miscfs/procfs/procfs_fpregs.c \
	$S/miscfs/procfs/procfs_linux.c $S/miscfs/procfs/procfs_mem.c \
	$S/miscfs/procfs/procfs_note.c $S/miscfs/procfs/procfs_regs.c \
	$S/miscfs/procfs/procfs_status.c $S/miscfs/procfs/procfs_subr.c \
	$S/miscfs/procfs/procfs_vfsops.c $S/miscfs/procfs/procfs_vnops.c \
	$S/miscfs/specfs/spec_vnops.c $S/miscfs/umapfs/umap_subr.c \
	$S/miscfs/umapfs/umap_vfsops.c $S/miscfs/umapfs/umap_vnops.c \
	$S/miscfs/union/union_subr.c $S/miscfs/union/union_vfsops.c \
	$S/miscfs/union/union_vnops.c $S/msdosfs/msdosfs_conv.c \
	$S/msdosfs/msdosfs_denode.c $S/msdosfs/msdosfs_fat.c \
	$S/msdosfs/msdosfs_lookup.c $S/msdosfs/msdosfs_vfsops.c \
	$S/msdosfs/msdosfs_vnops.c $S/net/bpf.c $S/net/bpf_filter.c \
	$S/net/if.c $S/net/if_ethersubr.c $S/net/if_fddisubr.c \
	$S/net/if_spppsubr.c $S/net/if_loop.c $S/net/if_media.c \
	$S/net/if_sl.c $S/net/if_ppp.c $S/net/ppp_tty.c $S/net/bsd-comp.c \
	$S/net/ppp-deflate.c $S/net/zlib.c $S/net/if_tun.c \
	$S/net/if_bridge.c $S/net/bridgestp.c $S/net/if_vlan.c \
	$S/net/radix.c $S/net/raw_cb.c $S/net/raw_usrreq.c $S/net/route.c \
	$S/net/rtsock.c $S/net/slcompress.c $S/net/if_enc.c \
	$S/net/if_gre.c $S/netinet/if_ether.c $S/netinet/in4_cksum.c \
	$S/netinet/igmp.c $S/netinet/in.c $S/netinet/in_pcb.c \
	$S/netinet/in_proto.c $S/netinet/ip_icmp.c $S/netinet/ip_id.c \
	$S/netinet/ip_input.c $S/netinet/ip_output.c $S/netinet/raw_ip.c \
	$S/netinet/tcp_debug.c $S/netinet/tcp_input.c \
	$S/netinet/tcp_output.c $S/netinet/tcp_subr.c \
	$S/netinet/tcp_timer.c $S/netinet/tcp_usrreq.c \
	$S/netinet/udp_usrreq.c $S/netinet/ip_gre.c $S/netinet/ip_ipsp.c \
	$S/netinet/ip_spd.c $S/netinet/ip_ipip.c $S/netinet/ip_ether.c \
	$S/netinet/ipsec_input.c $S/netinet/ipsec_output.c \
	$S/netinet/ip_esp.c $S/netinet/ip_ah.c $S/netinet/ip_carp.c \
	$S/netinet/ip_ipcomp.c $S/crypto/rijndael.c $S/crypto/rmd160.c \
	$S/crypto/sha1.c $S/crypto/sha2.c $S/crypto/blf.c \
	$S/crypto/cast.c $S/crypto/skipjack.c $S/crypto/ecb_enc.c \
	$S/crypto/set_key.c $S/crypto/ecb3_enc.c $S/crypto/crypto.c \
	$S/crypto/cryptodev.c $S/crypto/criov.c $S/crypto/cryptosoft.c \
	$S/crypto/xform.c $S/crypto/deflate.c $S/crypto/arc4.c \
	$S/nfs/krpc_subr.c $S/nfs/nfs_bio.c $S/nfs/nfs_boot.c \
	$S/nfs/nfs_node.c $S/nfs/nfs_serv.c $S/nfs/nfs_socket.c \
	$S/nfs/nfs_srvcache.c $S/nfs/nfs_subs.c $S/nfs/nfs_syscalls.c \
	$S/nfs/nfs_vfsops.c $S/nfs/nfs_vnops.c $S/ufs/ffs/ffs_alloc.c \
	$S/ufs/ffs/ffs_balloc.c $S/ufs/ffs/ffs_inode.c \
	$S/ufs/ffs/ffs_subr.c $S/ufs/ffs/ffs_softdep_stub.c \
	$S/ufs/ffs/ffs_tables.c $S/ufs/ffs/ffs_vfsops.c \
	$S/ufs/ffs/ffs_vnops.c $S/ufs/ffs/ffs_softdep.c \
	$S/ufs/mfs/mfs_vfsops.c $S/ufs/mfs/mfs_vnops.c \
	$S/ufs/ufs/ufs_bmap.c $S/ufs/ufs/ufs_dirhash.c \
	$S/ufs/ufs/ufs_extattr.c $S/ufs/ufs/ufs_ihash.c \
	$S/ufs/ufs/ufs_inode.c $S/ufs/ufs/ufs_lookup.c \
	$S/ufs/ufs/ufs_quota.c $S/ufs/ufs/ufs_quota_stub.c \
	$S/ufs/ufs/ufs_vfsops.c $S/ufs/ufs/ufs_vnops.c \
	$S/ufs/ext2fs/ext2fs_alloc.c $S/ufs/ext2fs/ext2fs_balloc.c \
	$S/ufs/ext2fs/ext2fs_bmap.c $S/ufs/ext2fs/ext2fs_bswap.c \
	$S/ufs/ext2fs/ext2fs_inode.c $S/ufs/ext2fs/ext2fs_lookup.c \
	$S/ufs/ext2fs/ext2fs_readwrite.c $S/ufs/ext2fs/ext2fs_subr.c \
	$S/ufs/ext2fs/ext2fs_vfsops.c $S/ufs/ext2fs/ext2fs_vnops.c \
	$S/xfs/xfs_common-bsd.c $S/xfs/xfs_deb.c $S/xfs/xfs_dev-bsd.c \
	$S/xfs/xfs_dev-common.c $S/xfs/xfs_message.c $S/xfs/xfs_node.c \
	$S/xfs/xfs_node-bsd.c $S/xfs/xfs_syscalls-common.c \
	$S/xfs/xfs_vfsops-bsd.c $S/xfs/xfs_vfsops-common.c \
	$S/xfs/xfs_vfsops-openbsd.c $S/xfs/xfs_vnodeops-bsd.c \
	$S/xfs/xfs_vnodeops-common.c $S/uvm/uvm_amap.c $S/uvm/uvm_anon.c \
	$S/uvm/uvm_aobj.c $S/uvm/uvm_device.c $S/uvm/uvm_fault.c \
	$S/uvm/uvm_glue.c $S/uvm/uvm_init.c $S/uvm/uvm_io.c \
	$S/uvm/uvm_km.c $S/uvm/uvm_map.c $S/uvm/uvm_meter.c \
	$S/uvm/uvm_mmap.c $S/uvm/uvm_page.c $S/uvm/uvm_pager.c \
	$S/uvm/uvm_pdaemon.c $S/uvm/uvm_pglist.c $S/uvm/uvm_stat.c \
	$S/uvm/uvm_swap.c $S/uvm/uvm_swap_encrypt.c $S/uvm/uvm_unix.c \
	$S/uvm/uvm_user.c $S/uvm/uvm_vnode.c $S/net/if_gif.c \
	$S/netinet/ip_ecn.c $S/netinet/in_gif.c $S/netinet6/in6_gif.c \
	$S/netinet6/in6_pcb.c $S/netinet6/in6.c \
	$S/netinet6/in6_ifattach.c $S/netinet6/in6_cksum.c \
	$S/netinet6/in6_src.c $S/netinet6/in6_proto.c $S/netinet6/dest6.c \
	$S/netinet6/frag6.c $S/netinet6/icmp6.c $S/netinet6/ip6_id.c \
	$S/netinet6/ip6_input.c $S/netinet6/ip6_forward.c \
	$S/netinet6/ip6_mroute.c $S/netinet6/ip6_output.c \
	$S/netinet6/route6.c $S/netinet6/mld6.c $S/netinet6/nd6.c \
	$S/netinet6/nd6_nbr.c $S/netinet6/nd6_rtr.c $S/netinet6/raw_ip6.c \
	$S/netinet6/udp6_output.c $S/net/pfkey.c $S/net/pfkeyv2.c \
	$S/net/pfkeyv2_parsemessage.c $S/net/pfkeyv2_convert.c \
	$S/arch/i386/i386/autoconf.c $S/arch/i386/i386/conf.c \
	$S/arch/i386/i386/db_disasm.c $S/arch/i386/i386/db_interface.c \
	$S/arch/i386/i386/db_memrw.c $S/arch/i386/i386/db_trace.c \
	$S/arch/i386/i386/disksubr.c $S/arch/i386/i386/est.c \
	$S/arch/i386/i386/gdt.c $S/arch/i386/i386/machdep.c \
	$S/arch/i386/i386/longrun.c $S/arch/i386/i386/mem.c \
	$S/arch/i386/i386/i686_mem.c $S/arch/i386/i386/k6_mem.c \
	$S/arch/i386/i386/p4tcc.c $S/arch/i386/i386/pmap.c \
	$S/arch/i386/i386/process_machdep.c \
	$S/arch/i386/i386/procfs_machdep.c \
	$S/arch/i386/i386/sys_machdep.c $S/arch/i386/i386/trap.c \
	$S/arch/i386/i386/vm_machdep.c $S/arch/i386/i386/dkcsum.c \
	$S/dev/cons.c $S/dev/cninit.c $S/arch/i386/i386/wscons_machdep.c \
	$S/dev/mii/mii.c $S/dev/mii/mii_physubr.c $S/dev/mii/ukphy_subr.c \
	$S/dev/mii/nsphy.c $S/dev/mii/nsphyter.c $S/dev/mii/qsphy.c \
	$S/dev/mii/inphy.c $S/dev/mii/iophy.c $S/dev/mii/eephy.c \
	$S/dev/mii/exphy.c $S/dev/mii/rlphy.c $S/dev/mii/lxtphy.c \
	$S/dev/mii/mtdphy.c $S/dev/mii/icsphy.c $S/dev/mii/sqphy.c \
	$S/dev/mii/tqphy.c $S/dev/mii/ukphy.c $S/dev/mii/dcphy.c \
	$S/dev/mii/bmtphy.c $S/dev/mii/brgphy.c $S/dev/mii/xmphy.c \
	$S/dev/mii/amphy.c $S/dev/mii/acphy.c $S/dev/mii/nsgphy.c \
	$S/dev/mii/urlphy.c $S/scsi/scsi_base.c $S/scsi/scsi_ioctl.c \
	$S/scsi/scsiconf.c $S/scsi/atapi_base.c $S/scsi/cd.c \
	$S/scsi/cd_scsi.c $S/scsi/cd_atapi.c $S/scsi/ch.c $S/scsi/sd.c \
	$S/scsi/sd_atapi.c $S/scsi/sd_scsi.c $S/scsi/st.c $S/scsi/ss.c \
	$S/scsi/ss_mustek.c $S/scsi/ss_scanjet.c $S/scsi/uk.c \
	$S/dev/i2o/iop.c $S/dev/i2o/ioprbs.c $S/dev/atapiscsi/atapiscsi.c \
	$S/dev/ata/wd.c $S/dev/ata/ata_wdc.c $S/dev/ata/ata.c \
	$S/arch/i386/i386/mainbus.c $S/dev/pci/pci.c $S/dev/pci/pci_map.c \
	$S/dev/pci/pci_quirks.c $S/dev/pci/pci_subr.c \
	$S/dev/pci/vga_pci.c $S/dev/pci/cy82c693.c $S/dev/pci/ahc_pci.c \
	$S/dev/pci/dpt_pci.c $S/dev/pci/adv_pci.c $S/dev/ic/advlib.c \
	$S/dev/ic/advmcode.c $S/dev/pci/adw_pci.c $S/dev/ic/adwlib.c \
	$S/dev/microcode/adw/adwmcode.c $S/dev/pci/bha_pci.c \
	$S/dev/pci/twe_pci.c $S/dev/pci/ami_pci.c $S/dev/pci/iop_pci.c \
	$S/dev/pci/eap.c $S/dev/pci/eso.c $S/dev/pci/opl_eso.c \
	$S/dev/pci/auich.c $S/dev/pci/emuxki.c $S/dev/pci/autri.c \
	$S/dev/pci/cs4280.c $S/dev/pci/cs4281.c $S/dev/pci/maestro.c \
	$S/dev/pci/esa.c $S/dev/pci/yds.c $S/dev/pci/opl_yds.c \
	$S/dev/pci/fms.c $S/dev/pci/fmsradio.c $S/dev/pci/auvia.c \
	$S/dev/pci/gdt_pci.c $S/dev/pci/aac_pci.c $S/dev/ic/aac.c \
	$S/dev/pci/cac_pci.c $S/dev/pci/isp_pci.c $S/dev/pci/mpt_pci.c \
	$S/dev/pci/if_de.c $S/dev/pci/if_ep_pci.c $S/dev/pci/if_fpa.c \
	$S/dev/pci/if_le_pci.c $S/dev/pci/siop_pci_common.c \
	$S/dev/pci/siop_pci.c $S/dev/pci/neo.c $S/dev/pci/pciide.c \
	$S/dev/pci/ppb.c $S/dev/pci/cy_pci.c $S/dev/pci/if_lmc.c \
	$S/dev/pci/if_lmc_common.c $S/dev/pci/if_lmc_media.c \
	$S/dev/pci/if_lmc_obsd.c $S/dev/pci/if_mtd_pci.c \
	$S/dev/pci/if_rl_pci.c $S/dev/pci/if_vr.c $S/dev/pci/if_tl.c \
	$S/dev/pci/if_txp.c $S/dev/pci/sv.c $S/dev/pci/bktr/bktr_audio.c \
	$S/dev/pci/bktr/bktr_card.c $S/dev/pci/bktr/bktr_core.c \
	$S/dev/pci/bktr/bktr_os.c $S/dev/pci/bktr/bktr_tuner.c \
	$S/dev/pci/if_xl_pci.c $S/dev/pci/if_fxp_pci.c $S/dev/pci/if_em.c \
	$S/dev/pci/if_em_hw.c $S/dev/pci/if_dc_pci.c $S/dev/pci/if_tx.c \
	$S/dev/pci/if_ti.c $S/dev/pci/if_ne_pci.c $S/dev/pci/lofn.c \
	$S/dev/pci/hifn7751.c $S/dev/pci/nofn.c $S/dev/pci/ubsec.c \
	$S/dev/pci/safe.c $S/dev/pci/if_wb.c $S/dev/pci/if_sf.c \
	$S/dev/pci/if_sis.c $S/dev/pci/if_ste.c $S/dev/pci/uhci_pci.c \
	$S/dev/pci/ohci_pci.c $S/dev/pci/pccbb.c $S/dev/pci/if_sk.c \
	$S/dev/pci/puc.c $S/dev/pci/pucdata.c $S/dev/pci/if_wi_pci.c \
	$S/dev/pci/if_an_pci.c $S/dev/pci/cmpci.c $S/dev/pci/iha_pci.c \
	$S/dev/pci/trm_pci.c $S/dev/pci/pcscp.c $S/dev/pci/if_nge.c \
	$S/dev/pci/if_bge.c $S/dev/pci/if_stge.c $S/dev/pci/viaenv.c \
	$S/dev/pci/if_bce.c $S/arch/i386/pci/pci_machdep.c \
	$S/arch/i386/pci/agp_machdep.c $S/dev/pci/agp_ali.c \
	$S/dev/pci/agp_amd.c $S/dev/pci/agp_i810.c $S/dev/pci/agp_intel.c \
	$S/dev/pci/agp_sis.c $S/dev/pci/agp_via.c \
	$S/arch/i386/pci/pciide_machdep.c \
	$S/arch/i386/pci/pcic_pci_machdep.c $S/arch/i386/pci/pchb.c \
	$S/arch/i386/pci/elan520.c $S/arch/i386/pci/geodesc.c \
	$S/arch/i386/pci/pcib.c $S/dev/ic/hme.c $S/dev/pci/if_hme_pci.c \
	$S/dev/isa/isa.c $S/dev/isa/isadma.c $S/dev/isa/ast.c \
	$S/dev/isa/cy_isa.c $S/dev/isa/pckbc_isa.c $S/dev/isa/vga_isa.c \
	$S/dev/isa/pcdisplay.c $S/dev/isa/bha_isa.c $S/dev/isa/aic_isa.c \
	$S/dev/isa/aha.c $S/dev/isa/seagate.c $S/dev/isa/uha_isa.c \
	$S/dev/isa/wds.c $S/dev/isa/opti.c $S/dev/isa/wdc_isa.c \
	$S/dev/isa/if_lc_isa.c $S/dev/isa/if_ne_isa.c $S/dev/isa/if_we.c \
	$S/dev/isa/elink.c $S/dev/isa/if_ec.c $S/dev/isa/if_eg.c \
	$S/dev/isa/if_el.c $S/dev/isa/if_ep_isa.c $S/dev/isa/if_ie.c \
	$S/dev/isa/if_ex.c $S/dev/isa/if_le.c $S/dev/isa/if_le_isa.c \
	$S/dev/isa/mpu401.c $S/dev/isa/mpu_isa.c $S/dev/isa/sbdsp.c \
	$S/dev/isa/sb.c $S/dev/isa/sb_isa.c $S/dev/isa/opl_sb.c \
	$S/dev/isa/pas.c $S/dev/isa/ad1848.c $S/dev/isa/ics2101.c \
	$S/dev/isa/pss.c $S/dev/isa/wss.c $S/dev/isa/wss_isa.c \
	$S/dev/isa/ess.c $S/dev/isa/opl_ess.c $S/dev/isa/gus.c \
	$S/dev/isa/gus_isa.c $S/dev/isa/pcppi.c $S/dev/isa/midi_pcppi.c \
	$S/dev/isa/lpt_isa.c $S/dev/isa/lm_isa.c \
	$S/dev/isa/nsclpcsio_isa.c $S/dev/isa/it.c \
	$S/arch/i386/isa/isa_machdep.c $S/arch/i386/isa/clock.c \
	$S/dev/clock_subr.c $S/arch/i386/isa/npx.c \
	$S/gnu/arch/i386/fpemul/errors.c \
	$S/gnu/arch/i386/fpemul/fpu_arith.c \
	$S/gnu/arch/i386/fpemul/fpu_aux.c \
	$S/gnu/arch/i386/fpemul/fpu_entry.c \
	$S/gnu/arch/i386/fpemul/fpu_etc.c \
	$S/gnu/arch/i386/fpemul/fpu_trig.c \
	$S/gnu/arch/i386/fpemul/get_address.c \
	$S/gnu/arch/i386/fpemul/load_store.c \
	$S/gnu/arch/i386/fpemul/poly_2xm1.c \
	$S/gnu/arch/i386/fpemul/poly_atan.c \
	$S/gnu/arch/i386/fpemul/poly_l2.c \
	$S/gnu/arch/i386/fpemul/poly_sin.c \
	$S/gnu/arch/i386/fpemul/poly_tan.c \
	$S/gnu/arch/i386/fpemul/reg_add_sub.c \
	$S/gnu/arch/i386/fpemul/reg_compare.c \
	$S/gnu/arch/i386/fpemul/reg_constant.c \
	$S/gnu/arch/i386/fpemul/reg_ld_str.c \
	$S/gnu/arch/i386/fpemul/reg_mul.c $S/arch/i386/isa/pccom.c \
	$S/arch/i386/isa/lms.c $S/arch/i386/isa/mms.c \
	$S/dev/wscons/wsdisplay.c $S/dev/wscons/wsdisplay_compat_usl.c \
	$S/dev/wscons/wsemulconf.c $S/dev/wscons/wsemul_vt100.c \
	$S/dev/wscons/wsemul_vt100_subr.c \
	$S/dev/wscons/wsemul_vt100_chars.c \
	$S/dev/wscons/wsemul_vt100_keys.c $S/dev/wscons/wsevent.c \
	$S/dev/wscons/wskbd.c $S/dev/wscons/wskbdutil.c \
	$S/dev/wscons/wsmouse.c $S/dev/wscons/wsmux.c \
	$S/dev/pckbc/pckbd.c $S/dev/pckbc/wskbdmap_mfii.c \
	$S/dev/pckbc/psm.c $S/dev/pckbc/psm_intelli.c $S/dev/isa/fdc.c \
	$S/dev/isa/fd.c $S/arch/i386/isa/ahc_isa.c \
	$S/arch/i386/i386/pctr.c $S/arch/i386/i386/mtrr.c \
	$S/dev/eisa/eisa.c $S/dev/eisa/aha1742.c $S/dev/eisa/ahc_eisa.c \
	$S/dev/eisa/dpt_eisa.c $S/dev/eisa/uha_eisa.c \
	$S/dev/eisa/cac_eisa.c $S/dev/eisa/if_ep_eisa.c \
	$S/dev/eisa/if_fea.c $S/arch/i386/eisa/eisa_machdep.c \
	$S/dev/isa/isapnp.c $S/dev/isa/isapnpdebug.c \
	$S/dev/isa/isapnpres.c $S/dev/isa/mpu_isapnp.c \
	$S/dev/isa/wdc_isapnp.c $S/dev/isa/aic_isapnp.c \
	$S/dev/isa/sb_isapnp.c $S/dev/isa/wss_isapnp.c \
	$S/dev/isa/ess_isapnp.c $S/dev/isa/if_an_isapnp.c \
	$S/dev/isa/if_le_isapnp.c $S/dev/isa/if_ep_isapnp.c \
	$S/dev/isa/if_ef_isapnp.c $S/dev/isa/if_ne_isapnp.c \
	$S/dev/isa/ym.c $S/dev/isa/ym_isapnp.c \
	$S/arch/i386/isa/isapnp_machdep.c $S/arch/i386/isa/joy.c \
	$S/arch/i386/isa/joy_isapnp.c $S/compat/aout/compat_aout.c \
	$S/compat/svr4/svr4_errno.c $S/compat/svr4/svr4_exec.c \
	$S/compat/svr4/svr4_fcntl.c $S/compat/svr4/svr4_filio.c \
	$S/compat/svr4/svr4_ioctl.c $S/compat/svr4/svr4_ipc.c \
	$S/compat/svr4/svr4_jioctl.c $S/compat/svr4/svr4_misc.c \
	$S/compat/svr4/svr4_net.c $S/compat/svr4/svr4_signal.c \
	$S/compat/svr4/svr4_socket.c $S/compat/svr4/svr4_sockio.c \
	$S/compat/svr4/svr4_stat.c $S/compat/svr4/svr4_stream.c \
	$S/compat/svr4/svr4_sysent.c $S/compat/svr4/svr4_termios.c \
	$S/compat/svr4/svr4_ttold.c $S/arch/i386/i386/svr4_machdep.c \
	$S/compat/ibcs2/ibcs2_errno.c $S/compat/ibcs2/ibcs2_exec.c \
	$S/compat/ibcs2/ibcs2_fcntl.c $S/compat/ibcs2/ibcs2_ioctl.c \
	$S/compat/ibcs2/ibcs2_ipc.c $S/compat/ibcs2/ibcs2_misc.c \
	$S/compat/ibcs2/ibcs2_signal.c $S/compat/ibcs2/ibcs2_socksys.c \
	$S/compat/ibcs2/ibcs2_stat.c $S/compat/ibcs2/ibcs2_sysent.c \
	$S/compat/linux/linux_blkio.c $S/compat/linux/linux_cdrom.c \
	$S/compat/linux/linux_error.c $S/compat/linux/linux_exec.c \
	$S/compat/linux/linux_fdio.c $S/compat/linux/linux_file.c \
	$S/compat/linux/linux_file64.c $S/compat/linux/linux_getcwd.c \
	$S/compat/linux/linux_hdio.c $S/compat/linux/linux_ioctl.c \
	$S/compat/linux/linux_ipc.c $S/compat/linux/linux_misc.c \
	$S/compat/linux/linux_mount.c $S/compat/linux/linux_resource.c \
	$S/compat/linux/linux_sched.c $S/compat/linux/linux_signal.c \
	$S/compat/linux/linux_socket.c $S/compat/linux/linux_sysent.c \
	$S/compat/linux/linux_termios.c $S/compat/linux/linux_dummy.c \
	$S/arch/i386/i386/linux_machdep.c $S/compat/bsdos/bsdos_exec.c \
	$S/compat/bsdos/bsdos_ioctl.c $S/compat/bsdos/bsdos_sysent.c \
	$S/compat/freebsd/freebsd_exec.c $S/compat/freebsd/freebsd_file.c \
	$S/compat/freebsd/freebsd_ioctl.c \
	$S/compat/freebsd/freebsd_misc.c \
	$S/compat/freebsd/freebsd_ptrace.c \
	$S/compat/freebsd/freebsd_signal.c \
	$S/compat/freebsd/freebsd_sysent.c \
	$S/arch/i386/i386/freebsd_machdep.c $S/compat/ossaudio/ossaudio.c \
	$S/arch/i386/i386/bios.c $S/arch/i386/i386/apm.c \
	$S/arch/i386/pci/pcibios.c $S/arch/i386/pci/pci_intr_fixup.c \
	$S/arch/i386/pci/pci_bus_fixup.c \
	$S/arch/i386/pci/pci_addr_fixup.c $S/arch/i386/pci/opti82c558.c \
	$S/arch/i386/pci/opti82c700.c $S/arch/i386/pci/piix.c \
	$S/arch/i386/pci/sis85c503.c $S/arch/i386/pci/via82c586.c \
	$S/arch/i386/pci/via8231.c $S/arch/i386/pci/amd756.c \
	$S/arch/i386/pci/ali1543.c $S/dev/cardbus/cardslot.c \
	$S/dev/cardbus/cardbus.c $S/dev/cardbus/cardbus_map.c \
	$S/dev/cardbus/cardbus_exrom.c $S/dev/cardbus/rbus.c \
	$S/dev/cardbus/if_xl_cardbus.c $S/dev/cardbus/if_dc_cardbus.c \
	$S/dev/cardbus/if_fxp_cardbus.c $S/dev/cardbus/if_rl_cardbus.c \
	$S/arch/i386/i386/rbus_machdep.c $S/dev/ic/i82365.c \
	$S/dev/isa/i82365_isa.c $S/dev/pci/i82365_pci.c \
	$S/dev/isa/i82365_isapnp.c $S/dev/isa/i82365_isasubr.c \
	$S/dev/ic/tcic2.c $S/dev/isa/tcic2_isa.c $S/dev/puc/com_puc.c \
	$S/dev/puc/lpt_puc.c $S/dev/pcmcia/pcmcia.c \
	$S/dev/pcmcia/pcmcia_cis.c $S/dev/pcmcia/pcmcia_cis_quirks.c \
	$S/dev/pcmcia/if_ep_pcmcia.c $S/dev/pcmcia/if_ne_pcmcia.c \
	$S/dev/pcmcia/aic_pcmcia.c $S/dev/pcmcia/com_pcmcia.c \
	$S/dev/pcmcia/wdc_pcmcia.c $S/dev/pcmcia/if_sm_pcmcia.c \
	$S/dev/pcmcia/if_xe.c $S/dev/pcmcia/if_wi_pcmcia.c \
	$S/dev/pcmcia/if_ray.c $S/dev/pcmcia/if_an_pcmcia.c \
	$S/dev/usb/usb.c $S/dev/usb/usbdi.c $S/dev/usb/usbdi_util.c \
	$S/dev/usb/usb_mem.c $S/dev/usb/usb_subr.c \
	$S/dev/usb/usb_quirks.c $S/dev/usb/uhub.c $S/dev/usb/uaudio.c \
	$S/dev/usb/ucom.c $S/dev/usb/ugen.c $S/dev/usb/hid.c \
	$S/dev/usb/uhidev.c $S/dev/usb/uhid.c $S/dev/usb/ukbd.c \
	$S/dev/usb/ukbdmap.c $S/dev/usb/ums.c $S/dev/usb/ulpt.c \
	$S/dev/usb/umass.c $S/dev/usb/umass_quirks.c \
	$S/dev/usb/umass_scsi.c $S/dev/usb/urio.c $S/dev/usb/uvisor.c \
	$S/dev/usb/if_aue.c $S/dev/usb/if_cue.c $S/dev/usb/if_kue.c \
	$S/dev/usb/if_upl.c $S/dev/usb/if_url.c $S/dev/usb/umodem.c \
	$S/dev/usb/uftdi.c $S/dev/usb/uplcom.c $S/dev/usb/ubsa.c \
	$S/dev/usb/uscanner.c $S/dev/usb/usscanner.c \
	$S/dev/usb/if_wi_usb.c $S/conf/swapgeneric.c

SFILES=	$S/arch/i386/i386/db_magic.s $S/arch/i386/i386/in_cksum.s \
	$S/arch/i386/i386/microtime.s $S/arch/i386/i386/random.s \
	$S/gnu/arch/i386/fpemul/div_small.s \
	$S/gnu/arch/i386/fpemul/poly_div.s \
	$S/gnu/arch/i386/fpemul/poly_mul64.s \
	$S/gnu/arch/i386/fpemul/polynomial.s \
	$S/gnu/arch/i386/fpemul/reg_div.s \
	$S/gnu/arch/i386/fpemul/reg_norm.s \
	$S/gnu/arch/i386/fpemul/reg_round.s \
	$S/gnu/arch/i386/fpemul/reg_u_add.s \
	$S/gnu/arch/i386/fpemul/reg_u_div.s \
	$S/gnu/arch/i386/fpemul/reg_u_mul.s \
	$S/gnu/arch/i386/fpemul/reg_u_sub.s \
	$S/gnu/arch/i386/fpemul/wm_shrx.s \
	$S/gnu/arch/i386/fpemul/wm_sqrt.s

# load lines for config "xxx" will be emitted as:
# xxx: ${SYSTEM_DEP} swapxxx.o
#	${SYSTEM_LD_HEAD}
#	${SYSTEM_LD} swapxxx.o
#	${SYSTEM_LD_TAIL}
SYSTEM_OBJ=	locore.o \
		param.o ioconf.o ${OBJS} ${LIBKERN} ${LIBCOMPAT}
SYSTEM_DEP=	Makefile ${SYSTEM_OBJ}
SYSTEM_LD_HEAD=	rm -f $@
SYSTEM_LD=	@echo ${LD} ${LINKFLAGS} -o $@ '$${SYSTEM_OBJ}' vers.o; \
		${LD} ${LINKFLAGS} -o $@ ${SYSTEM_OBJ} vers.o
SYSTEM_LD_TAIL=	@${SIZE} $@; chmod 755 $@

DEBUG?=
.if ${DEBUG} == "-g"
LINKFLAGS+=	-X
SYSTEM_LD_TAIL+=; \
		echo cp $@ $@.gdb; rm -f $@.gdb; cp $@ $@.gdb; \
		echo ${STRIP} ${STRIPFLAGS} $@; ${STRIP} ${STRIPFLAGS} $@
.else
LINKFLAGS+=	-x
.endif

all: bsd

bsd: ${SYSTEM_DEP} swapgeneric.o newvers
	${SYSTEM_LD_HEAD}
	${SYSTEM_LD} swapgeneric.o
	${SYSTEM_LD_TAIL}

swapgeneric.o: $S/conf/swapgeneric.c
	${NORMAL_C}


assym.h: $S/kern/genassym.sh ${I386}/i386/genassym.cf Makefile
	sh $S/kern/genassym.sh ${CC} ${CFLAGS} ${CPPFLAGS} \
	    ${PARAM} < ${I386}/i386/genassym.cf > assym.h.tmp && \
	    mv -f assym.h.tmp assym.h

param.c: $S/conf/param.c
	rm -f param.c
	cp $S/conf/param.c .

param.o: param.c Makefile
	${NORMAL_C_C}

ioconf.o: ioconf.c
	${NORMAL_C}

newvers: ${SYSTEM_DEP} ${SYSTEM_SWAP_DEP}
	sh $S/conf/newvers.sh
	${CC} ${CFLAGS} ${CPPFLAGS} ${PROF} -c vers.c


clean::
	rm -f eddep *bsd bsd.gdb tags *.[io] [a-z]*.s \
	    [Ee]rrs linterrs makelinks assym.h

lint:
	@lint -hbxncez -Dvolatile= ${CPPFLAGS} ${PARAM} -UKGDB \
	    ${CFILES} ioconf.c param.c | \
	    grep -v 'static function .* unused'

tags:
	@echo "see $S/kern/Makefile for tags"

links:
	egrep '#if' ${CFILES} | sed -f $S/conf/defines | \
	  sed -e 's/:.*//' -e 's/\.c/.o/' | sort -u > dontlink
	echo ${CFILES} | tr -s ' ' '\12' | sed 's/\.c/.o/' | \
	  sort -u | comm -23 - dontlink | \
	  sed 's,.*/\(.*.o\),rm -f \1; ln -s ../GENERIC/\1 \1,' > makelinks
	sh makelinks && rm -f dontlink makelinks

SRCS=	${I386}/i386/locore.s \
	param.c ioconf.c ${CFILES} ${SFILES}
depend:: .depend
.depend: ${SRCS} assym.h param.c ${APMINC}
	${MKDEP} ${AFLAGS} ${CPPFLAGS} ${I386}/i386/locore.s
	${MKDEP} -a ${CFLAGS} ${CPPFLAGS} param.c ioconf.c ${CFILES}
	${MKDEP} -a ${AFLAGS} ${CPPFLAGS} ${SFILES}
	sh $S/kern/genassym.sh ${MKDEP} -f assym.dep ${CFLAGS} \
	    ${CPPFLAGS} < ${I386}/i386/genassym.cf
	@sed -e 's/.*\.o:.* /assym.h: /' < assym.dep >> .depend
	@rm -f assym.dep


# depend on root or device configuration
autoconf.o conf.o: Makefile
 
# depend on network or filesystem configuration 
uipc_domain.o uipc_proto.o vfs_conf.o: Makefile 
if.o if_tun.o if_loop.o if_ethersubr.o: Makefile
if_arp.o if_ether.o: Makefile
ip_input.o ip_output.o in_pcb.o in_proto.o: Makefile
tcp_subr.o tcp_timer.o tcp_output.o: Makefile

# depend on maxusers
machdep.o: Makefile

# depend on CPU configuration 
locore.o machdep.o: Makefile


locore.o: ${I386}/i386/locore.s assym.h
	${NORMAL_S}

# The install target can be redefined by putting a
# install-kernel-${MACHINE_NAME} target into /etc/mk.conf
MACHINE_NAME!=  uname -n
install: install-kernel-${MACHINE_NAME}
.if !target(install-kernel-${MACHINE_NAME}})
install-kernel-${MACHINE_NAME}:
	rm -f /obsd
	ln /bsd /obsd
	cp bsd /nbsd
	mv /nbsd /bsd
.endif

smc93cx6.o: $S/dev/ic/smc93cx6.c
	${NORMAL_C}

pcdisplay_subr.o: $S/dev/ic/pcdisplay_subr.c
	${NORMAL_C}

pcdisplay_chars.o: $S/dev/ic/pcdisplay_chars.c
	${NORMAL_C}

vga.o: $S/dev/ic/vga.c
	${NORMAL_C}

vga_subr.o: $S/dev/ic/vga_subr.c
	${NORMAL_C}

mii_bitbang.o: $S/dev/mii/mii_bitbang.c
	${NORMAL_C}

wdc.o: $S/dev/ic/wdc.c
	${NORMAL_C}

aic7xxx.o: $S/dev/ic/aic7xxx.c
	${NORMAL_C}

aic7xxx_openbsd.o: $S/dev/ic/aic7xxx_openbsd.c
	${NORMAL_C}

aic7xxx_seeprom.o: $S/dev/ic/aic7xxx_seeprom.c
	${NORMAL_C}

aic6360.o: $S/dev/ic/aic6360.c
	${NORMAL_C}

dpt.o: $S/dev/ic/dpt.c
	${NORMAL_C}

adv.o: $S/dev/ic/adv.c
	${NORMAL_C}

adw.o: $S/dev/ic/adw.c
	${NORMAL_C}

bha.o: $S/dev/ic/bha.c
	${NORMAL_C}

gdt_common.o: $S/dev/ic/gdt_common.c
	${NORMAL_C}

twe.o: $S/dev/ic/twe.c
	${NORMAL_C}

cac.o: $S/dev/ic/cac.c
	${NORMAL_C}

ami.o: $S/dev/ic/ami.c
	${NORMAL_C}

isp.o: $S/dev/ic/isp.c
	${NORMAL_C}

isp_openbsd.o: $S/dev/ic/isp_openbsd.c
	${NORMAL_C}

mpt.o: $S/dev/ic/mpt.c
	${NORMAL_C}

mpt_debug.o: $S/dev/ic/mpt_debug.c
	${NORMAL_C}

mpt_openbsd.o: $S/dev/ic/mpt_openbsd.c
	${NORMAL_C}

uha.o: $S/dev/ic/uha.c
	${NORMAL_C}

ncr53c9x.o: $S/dev/ic/ncr53c9x.c
	${NORMAL_C}

siop_common.o: $S/dev/ic/siop_common.c
	${NORMAL_C}

siop.o: $S/dev/ic/siop.c
	${NORMAL_C}

elink3.o: $S/dev/ic/elink3.c
	${NORMAL_C}

lemac.o: $S/dev/ic/lemac.c
	${NORMAL_C}

if_wi.o: $S/dev/ic/if_wi.c
	${NORMAL_C}

if_wi_hostap.o: $S/dev/ic/if_wi_hostap.c
	${NORMAL_C}

an.o: $S/dev/ic/an.c
	${NORMAL_C}

am7990.o: $S/dev/ic/am7990.c
	${NORMAL_C}

xl.o: $S/dev/ic/xl.c
	${NORMAL_C}

fxp.o: $S/dev/ic/fxp.c
	${NORMAL_C}

mtd8xx.o: $S/dev/ic/mtd8xx.c
	${NORMAL_C}

rtl81x9.o: $S/dev/ic/rtl81x9.c
	${NORMAL_C}

dc.o: $S/dev/ic/dc.c
	${NORMAL_C}

smc91cxx.o: $S/dev/ic/smc91cxx.c
	${NORMAL_C}

ne2000.o: $S/dev/ic/ne2000.c
	${NORMAL_C}

dl10019.o: $S/dev/ic/dl10019.c
	${NORMAL_C}

ax88190.o: $S/dev/ic/ax88190.c
	${NORMAL_C}

pckbc.o: $S/dev/ic/pckbc.c
	${NORMAL_C}

opl.o: $S/dev/ic/opl.c
	${NORMAL_C}

oplinstrs.o: $S/dev/ic/oplinstrs.c
	${NORMAL_C}

ac97.o: $S/dev/ic/ac97.c
	${NORMAL_C}

cy.o: $S/dev/ic/cy.c
	${NORMAL_C}

lpt.o: $S/dev/ic/lpt.c
	${NORMAL_C}

iha.o: $S/dev/ic/iha.c
	${NORMAL_C}

trm.o: $S/dev/ic/trm.c
	${NORMAL_C}

nslm7x.o: $S/dev/ic/nslm7x.c
	${NORMAL_C}

uhci.o: $S/dev/usb/uhci.c
	${NORMAL_C}

ohci.o: $S/dev/usb/ohci.c
	${NORMAL_C}

radio.o: $S/dev/radio.c
	${NORMAL_C}

ksyms.o: $S/dev/ksyms.c
	${NORMAL_C}

pf.o: $S/net/pf.c
	${NORMAL_C}

pf_norm.o: $S/net/pf_norm.c
	${NORMAL_C}

pf_ioctl.o: $S/net/pf_ioctl.c
	${NORMAL_C}

pf_table.o: $S/net/pf_table.c
	${NORMAL_C}

pf_osfp.o: $S/net/pf_osfp.c
	${NORMAL_C}

pf_if.o: $S/net/pf_if.c
	${NORMAL_C}

if_pflog.o: $S/net/if_pflog.c
	${NORMAL_C}

if_pfsync.o: $S/net/if_pfsync.c
	${NORMAL_C}

bio.o: $S/dev/bio.c
	${NORMAL_C}

altq_subr.o: $S/altq/altq_subr.c
	${NORMAL_C}

altq_red.o: $S/altq/altq_red.c
	${NORMAL_C}

altq_cbq.o: $S/altq/altq_cbq.c
	${NORMAL_C}

altq_rmclass.o: $S/altq/altq_rmclass.c
	${NORMAL_C}

altq_hfsc.o: $S/altq/altq_hfsc.c
	${NORMAL_C}

altq_priq.o: $S/altq/altq_priq.c
	${NORMAL_C}

db_access.o: $S/ddb/db_access.c
	${NORMAL_C}

db_aout.o: $S/ddb/db_aout.c
	${NORMAL_C}

db_break.o: $S/ddb/db_break.c
	${NORMAL_C}

db_command.o: $S/ddb/db_command.c
	${NORMAL_C}

db_elf.o: $S/ddb/db_elf.c
	${NORMAL_C}

db_examine.o: $S/ddb/db_examine.c
	${NORMAL_C}

db_expr.o: $S/ddb/db_expr.c
	${NORMAL_C}

db_input.o: $S/ddb/db_input.c
	${NORMAL_C}

db_lex.o: $S/ddb/db_lex.c
	${NORMAL_C}

db_output.o: $S/ddb/db_output.c
	${NORMAL_C}

db_print.o: $S/ddb/db_print.c
	${NORMAL_C}

db_run.o: $S/ddb/db_run.c
	${NORMAL_C}

db_sym.o: $S/ddb/db_sym.c
	${NORMAL_C}

db_trap.o: $S/ddb/db_trap.c
	${NORMAL_C}

db_variables.o: $S/ddb/db_variables.c
	${NORMAL_C}

db_watch.o: $S/ddb/db_watch.c
	${NORMAL_C}

db_write_cmd.o: $S/ddb/db_write_cmd.c
	${NORMAL_C}

db_usrreq.o: $S/ddb/db_usrreq.c
	${NORMAL_C}

db_hangman.o: $S/ddb/db_hangman.c
	${NORMAL_C}

auconv.o: $S/dev/auconv.c
	${NORMAL_C}

audio.o: $S/dev/audio.c
	${NORMAL_C}

ccd.o: $S/dev/ccd.c
	${NORMAL_C}

pdq.o: $S/dev/ic/pdq.c
	${NORMAL_C}

pdq_ifsubr.o: $S/dev/ic/pdq_ifsubr.c
	${NORMAL_C}

dp8390.o: $S/dev/ic/dp8390.c
	${NORMAL_C}

rtl80x9.o: $S/dev/ic/rtl80x9.c
	${NORMAL_C}

tea5757.o: $S/dev/ic/tea5757.c
	${NORMAL_C}

midi.o: $S/dev/midi.c
	${NORMAL_C}

midisyn.o: $S/dev/midisyn.c
	${NORMAL_C}

mulaw.o: $S/dev/mulaw.c
	${NORMAL_C}

sequencer.o: $S/dev/sequencer.c
	${NORMAL_C}

systrace.o: $S/dev/systrace.c
	${NORMAL_C}

vnd.o: $S/dev/vnd.c
	${NORMAL_C}

rnd.o: $S/dev/rnd.c
	${NORMAL_C}

cd9660_bmap.o: $S/isofs/cd9660/cd9660_bmap.c
	${NORMAL_C}

cd9660_lookup.o: $S/isofs/cd9660/cd9660_lookup.c
	${NORMAL_C}

cd9660_node.o: $S/isofs/cd9660/cd9660_node.c
	${NORMAL_C}

cd9660_rrip.o: $S/isofs/cd9660/cd9660_rrip.c
	${NORMAL_C}

cd9660_util.o: $S/isofs/cd9660/cd9660_util.c
	${NORMAL_C}

cd9660_vfsops.o: $S/isofs/cd9660/cd9660_vfsops.c
	${NORMAL_C}

cd9660_vnops.o: $S/isofs/cd9660/cd9660_vnops.c
	${NORMAL_C}

exec_aout.o: $S/kern/exec_aout.c
	${NORMAL_C}

exec_conf.o: $S/kern/exec_conf.c
	${NORMAL_C}

exec_ecoff.o: $S/kern/exec_ecoff.c
	${NORMAL_C}

exec_elf32.o: $S/kern/exec_elf32.c
	${NORMAL_C}

exec_elf64.o: $S/kern/exec_elf64.c
	${NORMAL_C}

exec_script.o: $S/kern/exec_script.c
	${NORMAL_C}

exec_subr.o: $S/kern/exec_subr.c
	${NORMAL_C}

init_main.o: $S/kern/init_main.c
	${NORMAL_C}

init_sysent.o: $S/kern/init_sysent.c
	${NORMAL_C}

kern_acct.o: $S/kern/kern_acct.c
	${NORMAL_C}

kern_clock.o: $S/kern/kern_clock.c
	${NORMAL_C}

kern_descrip.o: $S/kern/kern_descrip.c
	${NORMAL_C}

kern_event.o: $S/kern/kern_event.c
	${NORMAL_C}

kern_exec.o: $S/kern/kern_exec.c
	${NORMAL_C}

kern_exit.o: $S/kern/kern_exit.c
	${NORMAL_C}

kern_fork.o: $S/kern/kern_fork.c
	${NORMAL_C}

kern_kthread.o: $S/kern/kern_kthread.c
	${NORMAL_C}

kern_ktrace.o: $S/kern/kern_ktrace.c
	${NORMAL_C}

kern_lock.o: $S/kern/kern_lock.c
	${NORMAL_C}

kern_lkm.o: $S/kern/kern_lkm.c
	${NORMAL_C}

kern_malloc.o: $S/kern/kern_malloc.c
	${NORMAL_C}

kern_rwlock.o: $S/kern/kern_rwlock.c
	${NORMAL_C}

kern_physio.o: $S/kern/kern_physio.c
	${NORMAL_C}

kern_proc.o: $S/kern/kern_proc.c
	${NORMAL_C}

kern_prot.o: $S/kern/kern_prot.c
	${NORMAL_C}

kern_resource.o: $S/kern/kern_resource.c
	${NORMAL_C}

kern_sig.o: $S/kern/kern_sig.c
	${NORMAL_C}

kern_subr.o: $S/kern/kern_subr.c
	${NORMAL_C}

kern_sysctl.o: $S/kern/kern_sysctl.c
	${NORMAL_C}

kern_synch.o: $S/kern/kern_synch.c
	${NORMAL_C}

kern_time.o: $S/kern/kern_time.c
	${NORMAL_C}

kern_timeout.o: $S/kern/kern_timeout.c
	${NORMAL_C}

kern_watchdog.o: $S/kern/kern_watchdog.c
	${NORMAL_C}

kern_xxx.o: $S/kern/kern_xxx.c
	${NORMAL_C}

subr_autoconf.o: $S/kern/subr_autoconf.c
	${NORMAL_C}

subr_disk.o: $S/kern/subr_disk.c
	${NORMAL_C}

subr_extent.o: $S/kern/subr_extent.c
	${NORMAL_C}

subr_log.o: $S/kern/subr_log.c
	${NORMAL_C}

subr_pool.o: $S/kern/subr_pool.c
	${NORMAL_C}

subr_prf.o: $S/kern/subr_prf.c
	${NORMAL_C}

subr_prof.o: $S/kern/subr_prof.c
	${NORMAL_C}

subr_userconf.o: $S/kern/subr_userconf.c
	${NORMAL_C}

subr_xxx.o: $S/kern/subr_xxx.c
	${NORMAL_C}

sys_generic.o: $S/kern/sys_generic.c
	${NORMAL_C}

sys_pipe.o: $S/kern/sys_pipe.c
	${NORMAL_C}

sys_process.o: $S/kern/sys_process.c
	${NORMAL_C}

sys_socket.o: $S/kern/sys_socket.c
	${NORMAL_C}

sysv_ipc.o: $S/kern/sysv_ipc.c
	${NORMAL_C}

sysv_msg.o: $S/kern/sysv_msg.c
	${NORMAL_C}

sysv_sem.o: $S/kern/sysv_sem.c
	${NORMAL_C}

sysv_shm.o: $S/kern/sysv_shm.c
	${NORMAL_C}

tty.o: $S/kern/tty.c
	${NORMAL_C}

tty_conf.o: $S/kern/tty_conf.c
	${NORMAL_C}

tty_pty.o: $S/kern/tty_pty.c
	${NORMAL_C}

tty_subr.o: $S/kern/tty_subr.c
	${NORMAL_C}

tty_tb.o: $S/kern/tty_tb.c
	${NORMAL_C}

tty_tty.o: $S/kern/tty_tty.c
	${NORMAL_C}

uipc_domain.o: $S/kern/uipc_domain.c
	${NORMAL_C}

uipc_mbuf.o: $S/kern/uipc_mbuf.c
	${NORMAL_C}

uipc_mbuf2.o: $S/kern/uipc_mbuf2.c
	${NORMAL_C}

uipc_proto.o: $S/kern/uipc_proto.c
	${NORMAL_C}

uipc_socket.o: $S/kern/uipc_socket.c
	${NORMAL_C}

uipc_socket2.o: $S/kern/uipc_socket2.c
	${NORMAL_C}

uipc_syscalls.o: $S/kern/uipc_syscalls.c
	${NORMAL_C}

uipc_usrreq.o: $S/kern/uipc_usrreq.c
	${NORMAL_C}

vfs_bio.o: $S/kern/vfs_bio.c
	${NORMAL_C}

vfs_cache.o: $S/kern/vfs_cache.c
	${NORMAL_C}

vfs_cluster.o: $S/kern/vfs_cluster.c
	${NORMAL_C}

vfs_conf.o: $S/kern/vfs_conf.c
	${NORMAL_C}

vfs_default.o: $S/kern/vfs_default.c
	${NORMAL_C}

vfs_init.o: $S/kern/vfs_init.c
	${NORMAL_C}

vfs_lockf.o: $S/kern/vfs_lockf.c
	${NORMAL_C}

vfs_lookup.o: $S/kern/vfs_lookup.c
	${NORMAL_C}

vfs_subr.o: $S/kern/vfs_subr.c
	${NORMAL_C}

vfs_sync.o: $S/kern/vfs_sync.c
	${NORMAL_C}

vfs_syscalls.o: $S/kern/vfs_syscalls.c
	${NORMAL_C}

vfs_vnops.o: $S/kern/vfs_vnops.c
	${NORMAL_C}

vnode_if.o: $S/kern/vnode_if.c
	${NORMAL_C}

dead_vnops.o: $S/miscfs/deadfs/dead_vnops.c
	${NORMAL_C}

layer_subr.o: $S/miscfs/genfs/layer_subr.c
	${NORMAL_C}

layer_vfsops.o: $S/miscfs/genfs/layer_vfsops.c
	${NORMAL_C}

layer_vnops.o: $S/miscfs/genfs/layer_vnops.c
	${NORMAL_C}

fdesc_vfsops.o: $S/miscfs/fdesc/fdesc_vfsops.c
	${NORMAL_C}

fdesc_vnops.o: $S/miscfs/fdesc/fdesc_vnops.c
	${NORMAL_C}

fifo_vnops.o: $S/miscfs/fifofs/fifo_vnops.c
	${NORMAL_C}

kernfs_vfsops.o: $S/miscfs/kernfs/kernfs_vfsops.c
	${NORMAL_C}

kernfs_vnops.o: $S/miscfs/kernfs/kernfs_vnops.c
	${NORMAL_C}

null_vfsops.o: $S/miscfs/nullfs/null_vfsops.c
	${NORMAL_C}

null_vnops.o: $S/miscfs/nullfs/null_vnops.c
	${NORMAL_C}

portal_vfsops.o: $S/miscfs/portal/portal_vfsops.c
	${NORMAL_C}

portal_vnops.o: $S/miscfs/portal/portal_vnops.c
	${NORMAL_C}

procfs_cmdline.o: $S/miscfs/procfs/procfs_cmdline.c
	${NORMAL_C}

procfs_ctl.o: $S/miscfs/procfs/procfs_ctl.c
	${NORMAL_C}

procfs_fpregs.o: $S/miscfs/procfs/procfs_fpregs.c
	${NORMAL_C}

procfs_linux.o: $S/miscfs/procfs/procfs_linux.c
	${NORMAL_C}

procfs_mem.o: $S/miscfs/procfs/procfs_mem.c
	${NORMAL_C}

procfs_note.o: $S/miscfs/procfs/procfs_note.c
	${NORMAL_C}

procfs_regs.o: $S/miscfs/procfs/procfs_regs.c
	${NORMAL_C}

procfs_status.o: $S/miscfs/procfs/procfs_status.c
	${NORMAL_C}

procfs_subr.o: $S/miscfs/procfs/procfs_subr.c
	${NORMAL_C}

procfs_vfsops.o: $S/miscfs/procfs/procfs_vfsops.c
	${NORMAL_C}

procfs_vnops.o: $S/miscfs/procfs/procfs_vnops.c
	${NORMAL_C}

spec_vnops.o: $S/miscfs/specfs/spec_vnops.c
	${NORMAL_C}

umap_subr.o: $S/miscfs/umapfs/umap_subr.c
	${NORMAL_C}

umap_vfsops.o: $S/miscfs/umapfs/umap_vfsops.c
	${NORMAL_C}

umap_vnops.o: $S/miscfs/umapfs/umap_vnops.c
	${NORMAL_C}

union_subr.o: $S/miscfs/union/union_subr.c
	${NORMAL_C}

union_vfsops.o: $S/miscfs/union/union_vfsops.c
	${NORMAL_C}

union_vnops.o: $S/miscfs/union/union_vnops.c
	${NORMAL_C}

msdosfs_conv.o: $S/msdosfs/msdosfs_conv.c
	${NORMAL_C}

msdosfs_denode.o: $S/msdosfs/msdosfs_denode.c
	${NORMAL_C}

msdosfs_fat.o: $S/msdosfs/msdosfs_fat.c
	${NORMAL_C}

msdosfs_lookup.o: $S/msdosfs/msdosfs_lookup.c
	${NORMAL_C}

msdosfs_vfsops.o: $S/msdosfs/msdosfs_vfsops.c
	${NORMAL_C}

msdosfs_vnops.o: $S/msdosfs/msdosfs_vnops.c
	${NORMAL_C}

bpf.o: $S/net/bpf.c
	${NORMAL_C}

bpf_filter.o: $S/net/bpf_filter.c
	${NORMAL_C}

if.o: $S/net/if.c
	${NORMAL_C}

if_ethersubr.o: $S/net/if_ethersubr.c
	${NORMAL_C}

if_fddisubr.o: $S/net/if_fddisubr.c
	${NORMAL_C}

if_spppsubr.o: $S/net/if_spppsubr.c
	${NORMAL_C}

if_loop.o: $S/net/if_loop.c
	${NORMAL_C}

if_media.o: $S/net/if_media.c
	${NORMAL_C}

if_sl.o: $S/net/if_sl.c
	${NORMAL_C}

if_ppp.o: $S/net/if_ppp.c
	${NORMAL_C}

ppp_tty.o: $S/net/ppp_tty.c
	${NORMAL_C}

bsd-comp.o: $S/net/bsd-comp.c
	${NORMAL_C}

ppp-deflate.o: $S/net/ppp-deflate.c
	${NORMAL_C}

zlib.o: $S/net/zlib.c
	${NORMAL_C}

if_tun.o: $S/net/if_tun.c
	${NORMAL_C}

if_bridge.o: $S/net/if_bridge.c
	${NORMAL_C}

bridgestp.o: $S/net/bridgestp.c
	${NORMAL_C}

if_vlan.o: $S/net/if_vlan.c
	${NORMAL_C}

radix.o: $S/net/radix.c
	${NORMAL_C}

raw_cb.o: $S/net/raw_cb.c
	${NORMAL_C}

raw_usrreq.o: $S/net/raw_usrreq.c
	${NORMAL_C}

route.o: $S/net/route.c
	${NORMAL_C}

rtsock.o: $S/net/rtsock.c
	${NORMAL_C}

slcompress.o: $S/net/slcompress.c
	${NORMAL_C}

if_enc.o: $S/net/if_enc.c
	${NORMAL_C}

if_gre.o: $S/net/if_gre.c
	${NORMAL_C}

if_ether.o: $S/netinet/if_ether.c
	${NORMAL_C}

in4_cksum.o: $S/netinet/in4_cksum.c
	${NORMAL_C}

igmp.o: $S/netinet/igmp.c
	${NORMAL_C}

in.o: $S/netinet/in.c
	${NORMAL_C}

in_pcb.o: $S/netinet/in_pcb.c
	${NORMAL_C}

in_proto.o: $S/netinet/in_proto.c
	${NORMAL_C}

ip_icmp.o: $S/netinet/ip_icmp.c
	${NORMAL_C}

ip_id.o: $S/netinet/ip_id.c
	${NORMAL_C}

ip_input.o: $S/netinet/ip_input.c
	${NORMAL_C}

ip_output.o: $S/netinet/ip_output.c
	${NORMAL_C}

raw_ip.o: $S/netinet/raw_ip.c
	${NORMAL_C}

tcp_debug.o: $S/netinet/tcp_debug.c
	${NORMAL_C}

tcp_input.o: $S/netinet/tcp_input.c
	${NORMAL_C}

tcp_output.o: $S/netinet/tcp_output.c
	${NORMAL_C}

tcp_subr.o: $S/netinet/tcp_subr.c
	${NORMAL_C}

tcp_timer.o: $S/netinet/tcp_timer.c
	${NORMAL_C}

tcp_usrreq.o: $S/netinet/tcp_usrreq.c
	${NORMAL_C}

udp_usrreq.o: $S/netinet/udp_usrreq.c
	${NORMAL_C}

ip_gre.o: $S/netinet/ip_gre.c
	${NORMAL_C}

ip_ipsp.o: $S/netinet/ip_ipsp.c
	${NORMAL_C}

ip_spd.o: $S/netinet/ip_spd.c
	${NORMAL_C}

ip_ipip.o: $S/netinet/ip_ipip.c
	${NORMAL_C}

ip_ether.o: $S/netinet/ip_ether.c
	${NORMAL_C}

ipsec_input.o: $S/netinet/ipsec_input.c
	${NORMAL_C}

ipsec_output.o: $S/netinet/ipsec_output.c
	${NORMAL_C}

ip_esp.o: $S/netinet/ip_esp.c
	${NORMAL_C}

ip_ah.o: $S/netinet/ip_ah.c
	${NORMAL_C}

ip_carp.o: $S/netinet/ip_carp.c
	${NORMAL_C}

ip_ipcomp.o: $S/netinet/ip_ipcomp.c
	${NORMAL_C}

rijndael.o: $S/crypto/rijndael.c
	${NORMAL_C}

rmd160.o: $S/crypto/rmd160.c
	${NORMAL_C}

sha1.o: $S/crypto/sha1.c
	${NORMAL_C}

sha2.o: $S/crypto/sha2.c
	${NORMAL_C}

blf.o: $S/crypto/blf.c
	${NORMAL_C}

cast.o: $S/crypto/cast.c
	${NORMAL_C}

skipjack.o: $S/crypto/skipjack.c
	${NORMAL_C}

ecb_enc.o: $S/crypto/ecb_enc.c
	${NORMAL_C}

set_key.o: $S/crypto/set_key.c
	${NORMAL_C}

ecb3_enc.o: $S/crypto/ecb3_enc.c
	${NORMAL_C}

crypto.o: $S/crypto/crypto.c
	${NORMAL_C}

cryptodev.o: $S/crypto/cryptodev.c
	${NORMAL_C}

criov.o: $S/crypto/criov.c
	${NORMAL_C}

cryptosoft.o: $S/crypto/cryptosoft.c
	${NORMAL_C}

xform.o: $S/crypto/xform.c
	${NORMAL_C}

deflate.o: $S/crypto/deflate.c
	${NORMAL_C}

arc4.o: $S/crypto/arc4.c
	${NORMAL_C}

krpc_subr.o: $S/nfs/krpc_subr.c
	${NORMAL_C}

nfs_bio.o: $S/nfs/nfs_bio.c
	${NORMAL_C}

nfs_boot.o: $S/nfs/nfs_boot.c
	${NORMAL_C}

nfs_node.o: $S/nfs/nfs_node.c
	${NORMAL_C}

nfs_serv.o: $S/nfs/nfs_serv.c
	${NORMAL_C}

nfs_socket.o: $S/nfs/nfs_socket.c
	${NORMAL_C}

nfs_srvcache.o: $S/nfs/nfs_srvcache.c
	${NORMAL_C}

nfs_subs.o: $S/nfs/nfs_subs.c
	${NORMAL_C}

nfs_syscalls.o: $S/nfs/nfs_syscalls.c
	${NORMAL_C}

nfs_vfsops.o: $S/nfs/nfs_vfsops.c
	${NORMAL_C}

nfs_vnops.o: $S/nfs/nfs_vnops.c
	${NORMAL_C}

ffs_alloc.o: $S/ufs/ffs/ffs_alloc.c
	${NORMAL_C}

ffs_balloc.o: $S/ufs/ffs/ffs_balloc.c
	${NORMAL_C}

ffs_inode.o: $S/ufs/ffs/ffs_inode.c
	${NORMAL_C}

ffs_subr.o: $S/ufs/ffs/ffs_subr.c
	${NORMAL_C}

ffs_softdep_stub.o: $S/ufs/ffs/ffs_softdep_stub.c
	${NORMAL_C}

ffs_tables.o: $S/ufs/ffs/ffs_tables.c
	${NORMAL_C}

ffs_vfsops.o: $S/ufs/ffs/ffs_vfsops.c
	${NORMAL_C}

ffs_vnops.o: $S/ufs/ffs/ffs_vnops.c
	${NORMAL_C}

ffs_softdep.o: $S/ufs/ffs/ffs_softdep.c
	${NORMAL_C}

mfs_vfsops.o: $S/ufs/mfs/mfs_vfsops.c
	${NORMAL_C}

mfs_vnops.o: $S/ufs/mfs/mfs_vnops.c
	${NORMAL_C}

ufs_bmap.o: $S/ufs/ufs/ufs_bmap.c
	${NORMAL_C}

ufs_dirhash.o: $S/ufs/ufs/ufs_dirhash.c
	${NORMAL_C}

ufs_extattr.o: $S/ufs/ufs/ufs_extattr.c
	${NORMAL_C}

ufs_ihash.o: $S/ufs/ufs/ufs_ihash.c
	${NORMAL_C}

ufs_inode.o: $S/ufs/ufs/ufs_inode.c
	${NORMAL_C}

ufs_lookup.o: $S/ufs/ufs/ufs_lookup.c
	${NORMAL_C}

ufs_quota.o: $S/ufs/ufs/ufs_quota.c
	${NORMAL_C}

ufs_quota_stub.o: $S/ufs/ufs/ufs_quota_stub.c
	${NORMAL_C}

ufs_vfsops.o: $S/ufs/ufs/ufs_vfsops.c
	${NORMAL_C}

ufs_vnops.o: $S/ufs/ufs/ufs_vnops.c
	${NORMAL_C}

ext2fs_alloc.o: $S/ufs/ext2fs/ext2fs_alloc.c
	${NORMAL_C}

ext2fs_balloc.o: $S/ufs/ext2fs/ext2fs_balloc.c
	${NORMAL_C}

ext2fs_bmap.o: $S/ufs/ext2fs/ext2fs_bmap.c
	${NORMAL_C}

ext2fs_bswap.o: $S/ufs/ext2fs/ext2fs_bswap.c
	${NORMAL_C}

ext2fs_inode.o: $S/ufs/ext2fs/ext2fs_inode.c
	${NORMAL_C}

ext2fs_lookup.o: $S/ufs/ext2fs/ext2fs_lookup.c
	${NORMAL_C}

ext2fs_readwrite.o: $S/ufs/ext2fs/ext2fs_readwrite.c
	${NORMAL_C}

ext2fs_subr.o: $S/ufs/ext2fs/ext2fs_subr.c
	${NORMAL_C}

ext2fs_vfsops.o: $S/ufs/ext2fs/ext2fs_vfsops.c
	${NORMAL_C}

ext2fs_vnops.o: $S/ufs/ext2fs/ext2fs_vnops.c
	${NORMAL_C}

xfs_common-bsd.o: $S/xfs/xfs_common-bsd.c
	${NORMAL_C}

xfs_deb.o: $S/xfs/xfs_deb.c
	${NORMAL_C}

xfs_dev-bsd.o: $S/xfs/xfs_dev-bsd.c
	${NORMAL_C}

xfs_dev-common.o: $S/xfs/xfs_dev-common.c
	${NORMAL_C}

xfs_message.o: $S/xfs/xfs_message.c
	${NORMAL_C}

xfs_node.o: $S/xfs/xfs_node.c
	${NORMAL_C}

xfs_node-bsd.o: $S/xfs/xfs_node-bsd.c
	${NORMAL_C}

xfs_syscalls-common.o: $S/xfs/xfs_syscalls-common.c
	${NORMAL_C}

xfs_vfsops-bsd.o: $S/xfs/xfs_vfsops-bsd.c
	${NORMAL_C}

xfs_vfsops-common.o: $S/xfs/xfs_vfsops-common.c
	${NORMAL_C}

xfs_vfsops-openbsd.o: $S/xfs/xfs_vfsops-openbsd.c
	${NORMAL_C}

xfs_vnodeops-bsd.o: $S/xfs/xfs_vnodeops-bsd.c
	${NORMAL_C}

xfs_vnodeops-common.o: $S/xfs/xfs_vnodeops-common.c
	${NORMAL_C}

uvm_amap.o: $S/uvm/uvm_amap.c
	${NORMAL_C}

uvm_anon.o: $S/uvm/uvm_anon.c
	${NORMAL_C}

uvm_aobj.o: $S/uvm/uvm_aobj.c
	${NORMAL_C}

uvm_device.o: $S/uvm/uvm_device.c
	${NORMAL_C}

uvm_fault.o: $S/uvm/uvm_fault.c
	${NORMAL_C}

uvm_glue.o: $S/uvm/uvm_glue.c
	${NORMAL_C}

uvm_init.o: $S/uvm/uvm_init.c
	${NORMAL_C}

uvm_io.o: $S/uvm/uvm_io.c
	${NORMAL_C}

uvm_km.o: $S/uvm/uvm_km.c
	${NORMAL_C}

uvm_map.o: $S/uvm/uvm_map.c
	${NORMAL_C}

uvm_meter.o: $S/uvm/uvm_meter.c
	${NORMAL_C}

uvm_mmap.o: $S/uvm/uvm_mmap.c
	${NORMAL_C}

uvm_page.o: $S/uvm/uvm_page.c
	${NORMAL_C}

uvm_pager.o: $S/uvm/uvm_pager.c
	${NORMAL_C}

uvm_pdaemon.o: $S/uvm/uvm_pdaemon.c
	${NORMAL_C}

uvm_pglist.o: $S/uvm/uvm_pglist.c
	${NORMAL_C}

uvm_stat.o: $S/uvm/uvm_stat.c
	${NORMAL_C}

uvm_swap.o: $S/uvm/uvm_swap.c
	${NORMAL_C}

uvm_swap_encrypt.o: $S/uvm/uvm_swap_encrypt.c
	${NORMAL_C}

uvm_unix.o: $S/uvm/uvm_unix.c
	${NORMAL_C}

uvm_user.o: $S/uvm/uvm_user.c
	${NORMAL_C}

uvm_vnode.o: $S/uvm/uvm_vnode.c
	${NORMAL_C}

if_gif.o: $S/net/if_gif.c
	${NORMAL_C}

ip_ecn.o: $S/netinet/ip_ecn.c
	${NORMAL_C}

in_gif.o: $S/netinet/in_gif.c
	${NORMAL_C}

in6_gif.o: $S/netinet6/in6_gif.c
	${NORMAL_C}

in6_pcb.o: $S/netinet6/in6_pcb.c
	${NORMAL_C}

in6.o: $S/netinet6/in6.c
	${NORMAL_C}

in6_ifattach.o: $S/netinet6/in6_ifattach.c
	${NORMAL_C}

in6_cksum.o: $S/netinet6/in6_cksum.c
	${NORMAL_C}

in6_src.o: $S/netinet6/in6_src.c
	${NORMAL_C}

in6_proto.o: $S/netinet6/in6_proto.c
	${NORMAL_C}

dest6.o: $S/netinet6/dest6.c
	${NORMAL_C}

frag6.o: $S/netinet6/frag6.c
	${NORMAL_C}

icmp6.o: $S/netinet6/icmp6.c
	${NORMAL_C}

ip6_id.o: $S/netinet6/ip6_id.c
	${NORMAL_C}

ip6_input.o: $S/netinet6/ip6_input.c
	${NORMAL_C}

ip6_forward.o: $S/netinet6/ip6_forward.c
	${NORMAL_C}

ip6_mroute.o: $S/netinet6/ip6_mroute.c
	${NORMAL_C}

ip6_output.o: $S/netinet6/ip6_output.c
	${NORMAL_C}

route6.o: $S/netinet6/route6.c
	${NORMAL_C}

mld6.o: $S/netinet6/mld6.c
	${NORMAL_C}

nd6.o: $S/netinet6/nd6.c
	${NORMAL_C}

nd6_nbr.o: $S/netinet6/nd6_nbr.c
	${NORMAL_C}

nd6_rtr.o: $S/netinet6/nd6_rtr.c
	${NORMAL_C}

raw_ip6.o: $S/netinet6/raw_ip6.c
	${NORMAL_C}

udp6_output.o: $S/netinet6/udp6_output.c
	${NORMAL_C}

pfkey.o: $S/net/pfkey.c
	${NORMAL_C}

pfkeyv2.o: $S/net/pfkeyv2.c
	${NORMAL_C}

pfkeyv2_parsemessage.o: $S/net/pfkeyv2_parsemessage.c
	${NORMAL_C}

pfkeyv2_convert.o: $S/net/pfkeyv2_convert.c
	${NORMAL_C}

autoconf.o: $S/arch/i386/i386/autoconf.c
	${NORMAL_C}

conf.o: $S/arch/i386/i386/conf.c
	${NORMAL_C}

db_disasm.o: $S/arch/i386/i386/db_disasm.c
	${NORMAL_C}

db_interface.o: $S/arch/i386/i386/db_interface.c
	${NORMAL_C}

db_memrw.o: $S/arch/i386/i386/db_memrw.c
	${NORMAL_C}

db_trace.o: $S/arch/i386/i386/db_trace.c
	${NORMAL_C}

db_magic.o: $S/arch/i386/i386/db_magic.s
	${NORMAL_S}

disksubr.o: $S/arch/i386/i386/disksubr.c
	${NORMAL_C}

est.o: $S/arch/i386/i386/est.c
	${NORMAL_C}

gdt.o: $S/arch/i386/i386/gdt.c
	${NORMAL_C}

in_cksum.o: $S/arch/i386/i386/in_cksum.s
	${NORMAL_S}

machdep.o: $S/arch/i386/i386/machdep.c
	${NORMAL_C}

longrun.o: $S/arch/i386/i386/longrun.c
	${NORMAL_C}

mem.o: $S/arch/i386/i386/mem.c
	${NORMAL_C}

i686_mem.o: $S/arch/i386/i386/i686_mem.c
	${NORMAL_C}

k6_mem.o: $S/arch/i386/i386/k6_mem.c
	${NORMAL_C}

microtime.o: $S/arch/i386/i386/microtime.s
	${NORMAL_S}

p4tcc.o: $S/arch/i386/i386/p4tcc.c
	${NORMAL_C}

pmap.o: $S/arch/i386/i386/pmap.c
	${NORMAL_C}

process_machdep.o: $S/arch/i386/i386/process_machdep.c
	${NORMAL_C}

procfs_machdep.o: $S/arch/i386/i386/procfs_machdep.c
	${NORMAL_C}

random.o: $S/arch/i386/i386/random.s
	${NORMAL_S}

sys_machdep.o: $S/arch/i386/i386/sys_machdep.c
	${NORMAL_C}

trap.o: $S/arch/i386/i386/trap.c
	${NORMAL_C}

vm_machdep.o: $S/arch/i386/i386/vm_machdep.c
	${NORMAL_C}

dkcsum.o: $S/arch/i386/i386/dkcsum.c
	${NORMAL_C}

cons.o: $S/dev/cons.c
	${NORMAL_C}

cninit.o: $S/dev/cninit.c
	${NORMAL_C}

wscons_machdep.o: $S/arch/i386/i386/wscons_machdep.c
	${NORMAL_C}

mii.o: $S/dev/mii/mii.c
	${NORMAL_C}

mii_physubr.o: $S/dev/mii/mii_physubr.c
	${NORMAL_C}

ukphy_subr.o: $S/dev/mii/ukphy_subr.c
	${NORMAL_C}

nsphy.o: $S/dev/mii/nsphy.c
	${NORMAL_C}

nsphyter.o: $S/dev/mii/nsphyter.c
	${NORMAL_C}

qsphy.o: $S/dev/mii/qsphy.c
	${NORMAL_C}

inphy.o: $S/dev/mii/inphy.c
	${NORMAL_C}

iophy.o: $S/dev/mii/iophy.c
	${NORMAL_C}

eephy.o: $S/dev/mii/eephy.c
	${NORMAL_C}

exphy.o: $S/dev/mii/exphy.c
	${NORMAL_C}

rlphy.o: $S/dev/mii/rlphy.c
	${NORMAL_C}

lxtphy.o: $S/dev/mii/lxtphy.c
	${NORMAL_C}

mtdphy.o: $S/dev/mii/mtdphy.c
	${NORMAL_C}

icsphy.o: $S/dev/mii/icsphy.c
	${NORMAL_C}

sqphy.o: $S/dev/mii/sqphy.c
	${NORMAL_C}

tqphy.o: $S/dev/mii/tqphy.c
	${NORMAL_C}

ukphy.o: $S/dev/mii/ukphy.c
	${NORMAL_C}

dcphy.o: $S/dev/mii/dcphy.c
	${NORMAL_C}

bmtphy.o: $S/dev/mii/bmtphy.c
	${NORMAL_C}

brgphy.o: $S/dev/mii/brgphy.c
	${NORMAL_C}

xmphy.o: $S/dev/mii/xmphy.c
	${NORMAL_C}

amphy.o: $S/dev/mii/amphy.c
	${NORMAL_C}

acphy.o: $S/dev/mii/acphy.c
	${NORMAL_C}

nsgphy.o: $S/dev/mii/nsgphy.c
	${NORMAL_C}

urlphy.o: $S/dev/mii/urlphy.c
	${NORMAL_C}

scsi_base.o: $S/scsi/scsi_base.c
	${NORMAL_C}

scsi_ioctl.o: $S/scsi/scsi_ioctl.c
	${NORMAL_C}

scsiconf.o: $S/scsi/scsiconf.c
	${NORMAL_C}

atapi_base.o: $S/scsi/atapi_base.c
	${NORMAL_C}

cd.o: $S/scsi/cd.c
	${NORMAL_C}

cd_scsi.o: $S/scsi/cd_scsi.c
	${NORMAL_C}

cd_atapi.o: $S/scsi/cd_atapi.c
	${NORMAL_C}

ch.o: $S/scsi/ch.c
	${NORMAL_C}

sd.o: $S/scsi/sd.c
	${NORMAL_C}

sd_atapi.o: $S/scsi/sd_atapi.c
	${NORMAL_C}

sd_scsi.o: $S/scsi/sd_scsi.c
	${NORMAL_C}

st.o: $S/scsi/st.c
	${NORMAL_C}

ss.o: $S/scsi/ss.c
	${NORMAL_C}

ss_mustek.o: $S/scsi/ss_mustek.c
	${NORMAL_C}

ss_scanjet.o: $S/scsi/ss_scanjet.c
	${NORMAL_C}

uk.o: $S/scsi/uk.c
	${NORMAL_C}

iop.o: $S/dev/i2o/iop.c
	${NORMAL_C}

ioprbs.o: $S/dev/i2o/ioprbs.c
	${NORMAL_C}

atapiscsi.o: $S/dev/atapiscsi/atapiscsi.c
	${NORMAL_C}

wd.o: $S/dev/ata/wd.c
	${NORMAL_C}

ata_wdc.o: $S/dev/ata/ata_wdc.c
	${NORMAL_C}

ata.o: $S/dev/ata/ata.c
	${NORMAL_C}

mainbus.o: $S/arch/i386/i386/mainbus.c
	${NORMAL_C}

pci.o: $S/dev/pci/pci.c
	${NORMAL_C}

pci_map.o: $S/dev/pci/pci_map.c
	${NORMAL_C}

pci_quirks.o: $S/dev/pci/pci_quirks.c
	${NORMAL_C}

pci_subr.o: $S/dev/pci/pci_subr.c
	${NORMAL_C}

vga_pci.o: $S/dev/pci/vga_pci.c
	${NORMAL_C}

cy82c693.o: $S/dev/pci/cy82c693.c
	${NORMAL_C}

ahc_pci.o: $S/dev/pci/ahc_pci.c
	${NORMAL_C}

dpt_pci.o: $S/dev/pci/dpt_pci.c
	${NORMAL_C}

adv_pci.o: $S/dev/pci/adv_pci.c
	${NORMAL_C}

advlib.o: $S/dev/ic/advlib.c
	${NORMAL_C}

advmcode.o: $S/dev/ic/advmcode.c
	${NORMAL_C}

adw_pci.o: $S/dev/pci/adw_pci.c
	${NORMAL_C}

adwlib.o: $S/dev/ic/adwlib.c
	${NORMAL_C}

adwmcode.o: $S/dev/microcode/adw/adwmcode.c
	${NORMAL_C}

bha_pci.o: $S/dev/pci/bha_pci.c
	${NORMAL_C}

twe_pci.o: $S/dev/pci/twe_pci.c
	${NORMAL_C}

ami_pci.o: $S/dev/pci/ami_pci.c
	${NORMAL_C}

iop_pci.o: $S/dev/pci/iop_pci.c
	${NORMAL_C}

eap.o: $S/dev/pci/eap.c
	${NORMAL_C}

eso.o: $S/dev/pci/eso.c
	${NORMAL_C}

opl_eso.o: $S/dev/pci/opl_eso.c
	${NORMAL_C}

auich.o: $S/dev/pci/auich.c
	${NORMAL_C}

emuxki.o: $S/dev/pci/emuxki.c
	${NORMAL_C}

autri.o: $S/dev/pci/autri.c
	${NORMAL_C}

cs4280.o: $S/dev/pci/cs4280.c
	${NORMAL_C}

cs4281.o: $S/dev/pci/cs4281.c
	${NORMAL_C}

maestro.o: $S/dev/pci/maestro.c
	${NORMAL_C}

esa.o: $S/dev/pci/esa.c
	${NORMAL_C}

yds.o: $S/dev/pci/yds.c
	${NORMAL_C}

opl_yds.o: $S/dev/pci/opl_yds.c
	${NORMAL_C}

fms.o: $S/dev/pci/fms.c
	${NORMAL_C}

fmsradio.o: $S/dev/pci/fmsradio.c
	${NORMAL_C}

auvia.o: $S/dev/pci/auvia.c
	${NORMAL_C}

gdt_pci.o: $S/dev/pci/gdt_pci.c
	${NORMAL_C}

aac_pci.o: $S/dev/pci/aac_pci.c
	${NORMAL_C}

aac.o: $S/dev/ic/aac.c
	${NORMAL_C}

cac_pci.o: $S/dev/pci/cac_pci.c
	${NORMAL_C}

isp_pci.o: $S/dev/pci/isp_pci.c
	${NORMAL_C}

mpt_pci.o: $S/dev/pci/mpt_pci.c
	${NORMAL_C}

if_de.o: $S/dev/pci/if_de.c
	${NORMAL_C}

if_ep_pci.o: $S/dev/pci/if_ep_pci.c
	${NORMAL_C}

if_fpa.o: $S/dev/pci/if_fpa.c
	${NORMAL_C}

if_le_pci.o: $S/dev/pci/if_le_pci.c
	${NORMAL_C}

siop_pci_common.o: $S/dev/pci/siop_pci_common.c
	${NORMAL_C}

siop_pci.o: $S/dev/pci/siop_pci.c
	${NORMAL_C}

neo.o: $S/dev/pci/neo.c
	${NORMAL_C}

pciide.o: $S/dev/pci/pciide.c
	${NORMAL_C}

ppb.o: $S/dev/pci/ppb.c
	${NORMAL_C}

cy_pci.o: $S/dev/pci/cy_pci.c
	${NORMAL_C}

if_lmc.o: $S/dev/pci/if_lmc.c
	${NORMAL_C}

if_lmc_common.o: $S/dev/pci/if_lmc_common.c
	${NORMAL_C}

if_lmc_media.o: $S/dev/pci/if_lmc_media.c
	${NORMAL_C}

if_lmc_obsd.o: $S/dev/pci/if_lmc_obsd.c
	${NORMAL_C}

if_mtd_pci.o: $S/dev/pci/if_mtd_pci.c
	${NORMAL_C}

if_rl_pci.o: $S/dev/pci/if_rl_pci.c
	${NORMAL_C}

if_vr.o: $S/dev/pci/if_vr.c
	${NORMAL_C}

if_tl.o: $S/dev/pci/if_tl.c
	${NORMAL_C}

if_txp.o: $S/dev/pci/if_txp.c
	${NORMAL_C}

sv.o: $S/dev/pci/sv.c
	${NORMAL_C}

bktr_audio.o: $S/dev/pci/bktr/bktr_audio.c
	${NORMAL_C}

bktr_card.o: $S/dev/pci/bktr/bktr_card.c
	${NORMAL_C}

bktr_core.o: $S/dev/pci/bktr/bktr_core.c
	${NORMAL_C}

bktr_os.o: $S/dev/pci/bktr/bktr_os.c
	${NORMAL_C}

bktr_tuner.o: $S/dev/pci/bktr/bktr_tuner.c
	${NORMAL_C}

if_xl_pci.o: $S/dev/pci/if_xl_pci.c
	${NORMAL_C}

if_fxp_pci.o: $S/dev/pci/if_fxp_pci.c
	${NORMAL_C}

if_em.o: $S/dev/pci/if_em.c
	${NORMAL_C}

if_em_hw.o: $S/dev/pci/if_em_hw.c
	${NORMAL_C}

if_dc_pci.o: $S/dev/pci/if_dc_pci.c
	${NORMAL_C}

if_tx.o: $S/dev/pci/if_tx.c
	${NORMAL_C}

if_ti.o: $S/dev/pci/if_ti.c
	${NORMAL_C}

if_ne_pci.o: $S/dev/pci/if_ne_pci.c
	${NORMAL_C}

lofn.o: $S/dev/pci/lofn.c
	${NORMAL_C}

hifn7751.o: $S/dev/pci/hifn7751.c
	${NORMAL_C}

nofn.o: $S/dev/pci/nofn.c
	${NORMAL_C}

ubsec.o: $S/dev/pci/ubsec.c
	${NORMAL_C}

safe.o: $S/dev/pci/safe.c
	${NORMAL_C}

if_wb.o: $S/dev/pci/if_wb.c
	${NORMAL_C}

if_sf.o: $S/dev/pci/if_sf.c
	${NORMAL_C}

if_sis.o: $S/dev/pci/if_sis.c
	${NORMAL_C}

if_ste.o: $S/dev/pci/if_ste.c
	${NORMAL_C}

uhci_pci.o: $S/dev/pci/uhci_pci.c
	${NORMAL_C}

ohci_pci.o: $S/dev/pci/ohci_pci.c
	${NORMAL_C}

pccbb.o: $S/dev/pci/pccbb.c
	${NORMAL_C}

if_sk.o: $S/dev/pci/if_sk.c
	${NORMAL_C}

puc.o: $S/dev/pci/puc.c
	${NORMAL_C}

pucdata.o: $S/dev/pci/pucdata.c
	${NORMAL_C}

if_wi_pci.o: $S/dev/pci/if_wi_pci.c
	${NORMAL_C}

if_an_pci.o: $S/dev/pci/if_an_pci.c
	${NORMAL_C}

cmpci.o: $S/dev/pci/cmpci.c
	${NORMAL_C}

iha_pci.o: $S/dev/pci/iha_pci.c
	${NORMAL_C}

trm_pci.o: $S/dev/pci/trm_pci.c
	${NORMAL_C}

pcscp.o: $S/dev/pci/pcscp.c
	${NORMAL_C}

if_nge.o: $S/dev/pci/if_nge.c
	${NORMAL_C}

if_bge.o: $S/dev/pci/if_bge.c
	${NORMAL_C}

if_stge.o: $S/dev/pci/if_stge.c
	${NORMAL_C}

viaenv.o: $S/dev/pci/viaenv.c
	${NORMAL_C}

if_bce.o: $S/dev/pci/if_bce.c
	${NORMAL_C}

pci_machdep.o: $S/arch/i386/pci/pci_machdep.c
	${NORMAL_C}

agp_machdep.o: $S/arch/i386/pci/agp_machdep.c
	${NORMAL_C}

agp_ali.o: $S/dev/pci/agp_ali.c
	${NORMAL_C}

agp_amd.o: $S/dev/pci/agp_amd.c
	${NORMAL_C}

agp_i810.o: $S/dev/pci/agp_i810.c
	${NORMAL_C}

agp_intel.o: $S/dev/pci/agp_intel.c
	${NORMAL_C}

agp_sis.o: $S/dev/pci/agp_sis.c
	${NORMAL_C}

agp_via.o: $S/dev/pci/agp_via.c
	${NORMAL_C}

pciide_machdep.o: $S/arch/i386/pci/pciide_machdep.c
	${NORMAL_C}

pcic_pci_machdep.o: $S/arch/i386/pci/pcic_pci_machdep.c
	${NORMAL_C}

pchb.o: $S/arch/i386/pci/pchb.c
	${NORMAL_C}

elan520.o: $S/arch/i386/pci/elan520.c
	${NORMAL_C}

geodesc.o: $S/arch/i386/pci/geodesc.c
	${NORMAL_C}

pcib.o: $S/arch/i386/pci/pcib.c
	${NORMAL_C}

hme.o: $S/dev/ic/hme.c
	${NORMAL_C}

if_hme_pci.o: $S/dev/pci/if_hme_pci.c
	${NORMAL_C}

isa.o: $S/dev/isa/isa.c
	${NORMAL_C}

isadma.o: $S/dev/isa/isadma.c
	${NORMAL_C}

ast.o: $S/dev/isa/ast.c
	${NORMAL_C}

cy_isa.o: $S/dev/isa/cy_isa.c
	${NORMAL_C}

pckbc_isa.o: $S/dev/isa/pckbc_isa.c
	${NORMAL_C}

vga_isa.o: $S/dev/isa/vga_isa.c
	${NORMAL_C}

pcdisplay.o: $S/dev/isa/pcdisplay.c
	${NORMAL_C}

bha_isa.o: $S/dev/isa/bha_isa.c
	${NORMAL_C}

aic_isa.o: $S/dev/isa/aic_isa.c
	${NORMAL_C}

aha.o: $S/dev/isa/aha.c
	${NORMAL_C}

seagate.o: $S/dev/isa/seagate.c
	${NORMAL_C}

uha_isa.o: $S/dev/isa/uha_isa.c
	${NORMAL_C}

wds.o: $S/dev/isa/wds.c
	${NORMAL_C}

opti.o: $S/dev/isa/opti.c
	${NORMAL_C}

wdc_isa.o: $S/dev/isa/wdc_isa.c
	${NORMAL_C}

if_lc_isa.o: $S/dev/isa/if_lc_isa.c
	${NORMAL_C}

if_ne_isa.o: $S/dev/isa/if_ne_isa.c
	${NORMAL_C}

if_we.o: $S/dev/isa/if_we.c
	${NORMAL_C}

elink.o: $S/dev/isa/elink.c
	${NORMAL_C}

if_ec.o: $S/dev/isa/if_ec.c
	${NORMAL_C}

if_eg.o: $S/dev/isa/if_eg.c
	${NORMAL_C}

if_el.o: $S/dev/isa/if_el.c
	${NORMAL_C}

if_ep_isa.o: $S/dev/isa/if_ep_isa.c
	${NORMAL_C}

if_ie.o: $S/dev/isa/if_ie.c
	${NORMAL_C}

if_ex.o: $S/dev/isa/if_ex.c
	${NORMAL_C}

if_le.o: $S/dev/isa/if_le.c
	${NORMAL_C}

if_le_isa.o: $S/dev/isa/if_le_isa.c
	${NORMAL_C}

mpu401.o: $S/dev/isa/mpu401.c
	${NORMAL_C}

mpu_isa.o: $S/dev/isa/mpu_isa.c
	${NORMAL_C}

sbdsp.o: $S/dev/isa/sbdsp.c
	${NORMAL_C}

sb.o: $S/dev/isa/sb.c
	${NORMAL_C}

sb_isa.o: $S/dev/isa/sb_isa.c
	${NORMAL_C}

opl_sb.o: $S/dev/isa/opl_sb.c
	${NORMAL_C}

pas.o: $S/dev/isa/pas.c
	${NORMAL_C}

ad1848.o: $S/dev/isa/ad1848.c
	${NORMAL_C}

ics2101.o: $S/dev/isa/ics2101.c
	${NORMAL_C}

pss.o: $S/dev/isa/pss.c
	${NORMAL_C}

wss.o: $S/dev/isa/wss.c
	${NORMAL_C}

wss_isa.o: $S/dev/isa/wss_isa.c
	${NORMAL_C}

ess.o: $S/dev/isa/ess.c
	${NORMAL_C}

opl_ess.o: $S/dev/isa/opl_ess.c
	${NORMAL_C}

gus.o: $S/dev/isa/gus.c
	${NORMAL_C}

gus_isa.o: $S/dev/isa/gus_isa.c
	${NORMAL_C}

pcppi.o: $S/dev/isa/pcppi.c
	${NORMAL_C}

midi_pcppi.o: $S/dev/isa/midi_pcppi.c
	${NORMAL_C}

lpt_isa.o: $S/dev/isa/lpt_isa.c
	${NORMAL_C}

lm_isa.o: $S/dev/isa/lm_isa.c
	${NORMAL_C}

nsclpcsio_isa.o: $S/dev/isa/nsclpcsio_isa.c
	${NORMAL_C}

it.o: $S/dev/isa/it.c
	${NORMAL_C}

isa_machdep.o: $S/arch/i386/isa/isa_machdep.c
	${NORMAL_C}

clock.o: $S/arch/i386/isa/clock.c
	${NORMAL_C}

clock_subr.o: $S/dev/clock_subr.c
	${NORMAL_C}

npx.o: $S/arch/i386/isa/npx.c
	${NORMAL_C}

div_small.o: $S/gnu/arch/i386/fpemul/div_small.s
	${NORMAL_S}

errors.o: $S/gnu/arch/i386/fpemul/errors.c
	${NORMAL_C}

fpu_arith.o: $S/gnu/arch/i386/fpemul/fpu_arith.c
	${NORMAL_C}

fpu_aux.o: $S/gnu/arch/i386/fpemul/fpu_aux.c
	${NORMAL_C}

fpu_entry.o: $S/gnu/arch/i386/fpemul/fpu_entry.c
	${NORMAL_C}

fpu_etc.o: $S/gnu/arch/i386/fpemul/fpu_etc.c
	${NORMAL_C}

fpu_trig.o: $S/gnu/arch/i386/fpemul/fpu_trig.c
	${NORMAL_C}

get_address.o: $S/gnu/arch/i386/fpemul/get_address.c
	${NORMAL_C}

load_store.o: $S/gnu/arch/i386/fpemul/load_store.c
	${NORMAL_C}

poly_2xm1.o: $S/gnu/arch/i386/fpemul/poly_2xm1.c
	${NORMAL_C}

poly_atan.o: $S/gnu/arch/i386/fpemul/poly_atan.c
	${NORMAL_C}

poly_div.o: $S/gnu/arch/i386/fpemul/poly_div.s
	${NORMAL_S}

poly_l2.o: $S/gnu/arch/i386/fpemul/poly_l2.c
	${NORMAL_C}

poly_mul64.o: $S/gnu/arch/i386/fpemul/poly_mul64.s
	${NORMAL_S}

poly_sin.o: $S/gnu/arch/i386/fpemul/poly_sin.c
	${NORMAL_C}

poly_tan.o: $S/gnu/arch/i386/fpemul/poly_tan.c
	${NORMAL_C}

polynomial.o: $S/gnu/arch/i386/fpemul/polynomial.s
	${NORMAL_S}

reg_add_sub.o: $S/gnu/arch/i386/fpemul/reg_add_sub.c
	${NORMAL_C}

reg_compare.o: $S/gnu/arch/i386/fpemul/reg_compare.c
	${NORMAL_C}

reg_constant.o: $S/gnu/arch/i386/fpemul/reg_constant.c
	${NORMAL_C}

reg_div.o: $S/gnu/arch/i386/fpemul/reg_div.s
	${NORMAL_S}

reg_ld_str.o: $S/gnu/arch/i386/fpemul/reg_ld_str.c
	${NORMAL_C}

reg_mul.o: $S/gnu/arch/i386/fpemul/reg_mul.c
	${NORMAL_C}

reg_norm.o: $S/gnu/arch/i386/fpemul/reg_norm.s
	${NORMAL_S}

reg_round.o: $S/gnu/arch/i386/fpemul/reg_round.s
	${NORMAL_S}

reg_u_add.o: $S/gnu/arch/i386/fpemul/reg_u_add.s
	${NORMAL_S}

reg_u_div.o: $S/gnu/arch/i386/fpemul/reg_u_div.s
	${NORMAL_S}

reg_u_mul.o: $S/gnu/arch/i386/fpemul/reg_u_mul.s
	${NORMAL_S}

reg_u_sub.o: $S/gnu/arch/i386/fpemul/reg_u_sub.s
	${NORMAL_S}

wm_shrx.o: $S/gnu/arch/i386/fpemul/wm_shrx.s
	${NORMAL_S}

wm_sqrt.o: $S/gnu/arch/i386/fpemul/wm_sqrt.s
	${NORMAL_S}

pccom.o: $S/arch/i386/isa/pccom.c
	${NORMAL_C}

lms.o: $S/arch/i386/isa/lms.c
	${NORMAL_C}

mms.o: $S/arch/i386/isa/mms.c
	${NORMAL_C}

wsdisplay.o: $S/dev/wscons/wsdisplay.c
	${NORMAL_C}

wsdisplay_compat_usl.o: $S/dev/wscons/wsdisplay_compat_usl.c
	${NORMAL_C}

wsemulconf.o: $S/dev/wscons/wsemulconf.c
	${NORMAL_C}

wsemul_vt100.o: $S/dev/wscons/wsemul_vt100.c
	${NORMAL_C}

wsemul_vt100_subr.o: $S/dev/wscons/wsemul_vt100_subr.c
	${NORMAL_C}

wsemul_vt100_chars.o: $S/dev/wscons/wsemul_vt100_chars.c
	${NORMAL_C}

wsemul_vt100_keys.o: $S/dev/wscons/wsemul_vt100_keys.c
	${NORMAL_C}

wsevent.o: $S/dev/wscons/wsevent.c
	${NORMAL_C}

wskbd.o: $S/dev/wscons/wskbd.c
	${NORMAL_C}

wskbdutil.o: $S/dev/wscons/wskbdutil.c
	${NORMAL_C}

wsmouse.o: $S/dev/wscons/wsmouse.c
	${NORMAL_C}

wsmux.o: $S/dev/wscons/wsmux.c
	${NORMAL_C}

pckbd.o: $S/dev/pckbc/pckbd.c
	${NORMAL_C}

wskbdmap_mfii.o: $S/dev/pckbc/wskbdmap_mfii.c
	${NORMAL_C}

psm.o: $S/dev/pckbc/psm.c
	${NORMAL_C}

psm_intelli.o: $S/dev/pckbc/psm_intelli.c
	${NORMAL_C}

fdc.o: $S/dev/isa/fdc.c
	${NORMAL_C}

fd.o: $S/dev/isa/fd.c
	${NORMAL_C}

ahc_isa.o: $S/arch/i386/isa/ahc_isa.c
	${NORMAL_C}

pctr.o: $S/arch/i386/i386/pctr.c
	${NORMAL_C}

mtrr.o: $S/arch/i386/i386/mtrr.c
	${NORMAL_C}

eisa.o: $S/dev/eisa/eisa.c
	${NORMAL_C}

aha1742.o: $S/dev/eisa/aha1742.c
	${NORMAL_C}

ahc_eisa.o: $S/dev/eisa/ahc_eisa.c
	${NORMAL_C}

dpt_eisa.o: $S/dev/eisa/dpt_eisa.c
	${NORMAL_C}

uha_eisa.o: $S/dev/eisa/uha_eisa.c
	${NORMAL_C}

cac_eisa.o: $S/dev/eisa/cac_eisa.c
	${NORMAL_C}

if_ep_eisa.o: $S/dev/eisa/if_ep_eisa.c
	${NORMAL_C}

if_fea.o: $S/dev/eisa/if_fea.c
	${NORMAL_C}

eisa_machdep.o: $S/arch/i386/eisa/eisa_machdep.c
	${NORMAL_C}

isapnp.o: $S/dev/isa/isapnp.c
	${NORMAL_C}

isapnpdebug.o: $S/dev/isa/isapnpdebug.c
	${NORMAL_C}

isapnpres.o: $S/dev/isa/isapnpres.c
	${NORMAL_C}

mpu_isapnp.o: $S/dev/isa/mpu_isapnp.c
	${NORMAL_C}

wdc_isapnp.o: $S/dev/isa/wdc_isapnp.c
	${NORMAL_C}

aic_isapnp.o: $S/dev/isa/aic_isapnp.c
	${NORMAL_C}

sb_isapnp.o: $S/dev/isa/sb_isapnp.c
	${NORMAL_C}

wss_isapnp.o: $S/dev/isa/wss_isapnp.c
	${NORMAL_C}

ess_isapnp.o: $S/dev/isa/ess_isapnp.c
	${NORMAL_C}

if_an_isapnp.o: $S/dev/isa/if_an_isapnp.c
	${NORMAL_C}

if_le_isapnp.o: $S/dev/isa/if_le_isapnp.c
	${NORMAL_C}

if_ep_isapnp.o: $S/dev/isa/if_ep_isapnp.c
	${NORMAL_C}

if_ef_isapnp.o: $S/dev/isa/if_ef_isapnp.c
	${NORMAL_C}

if_ne_isapnp.o: $S/dev/isa/if_ne_isapnp.c
	${NORMAL_C}

ym.o: $S/dev/isa/ym.c
	${NORMAL_C}

ym_isapnp.o: $S/dev/isa/ym_isapnp.c
	${NORMAL_C}

isapnp_machdep.o: $S/arch/i386/isa/isapnp_machdep.c
	${NORMAL_C}

joy.o: $S/arch/i386/isa/joy.c
	${NORMAL_C}

joy_isapnp.o: $S/arch/i386/isa/joy_isapnp.c
	${NORMAL_C}

compat_aout.o: $S/compat/aout/compat_aout.c
	${NORMAL_C}

svr4_errno.o: $S/compat/svr4/svr4_errno.c
	${NORMAL_C}

svr4_exec.o: $S/compat/svr4/svr4_exec.c
	${NORMAL_C}

svr4_fcntl.o: $S/compat/svr4/svr4_fcntl.c
	${NORMAL_C}

svr4_filio.o: $S/compat/svr4/svr4_filio.c
	${NORMAL_C}

svr4_ioctl.o: $S/compat/svr4/svr4_ioctl.c
	${NORMAL_C}

svr4_ipc.o: $S/compat/svr4/svr4_ipc.c
	${NORMAL_C}

svr4_jioctl.o: $S/compat/svr4/svr4_jioctl.c
	${NORMAL_C}

svr4_misc.o: $S/compat/svr4/svr4_misc.c
	${NORMAL_C}

svr4_net.o: $S/compat/svr4/svr4_net.c
	${NORMAL_C}

svr4_signal.o: $S/compat/svr4/svr4_signal.c
	${NORMAL_C}

svr4_socket.o: $S/compat/svr4/svr4_socket.c
	${NORMAL_C}

svr4_sockio.o: $S/compat/svr4/svr4_sockio.c
	${NORMAL_C}

svr4_stat.o: $S/compat/svr4/svr4_stat.c
	${NORMAL_C}

svr4_stream.o: $S/compat/svr4/svr4_stream.c
	${NORMAL_C}

svr4_sysent.o: $S/compat/svr4/svr4_sysent.c
	${NORMAL_C}

svr4_termios.o: $S/compat/svr4/svr4_termios.c
	${NORMAL_C}

svr4_ttold.o: $S/compat/svr4/svr4_ttold.c
	${NORMAL_C}

svr4_machdep.o: $S/arch/i386/i386/svr4_machdep.c
	${NORMAL_C}

ibcs2_errno.o: $S/compat/ibcs2/ibcs2_errno.c
	${NORMAL_C}

ibcs2_exec.o: $S/compat/ibcs2/ibcs2_exec.c
	${NORMAL_C}

ibcs2_fcntl.o: $S/compat/ibcs2/ibcs2_fcntl.c
	${NORMAL_C}

ibcs2_ioctl.o: $S/compat/ibcs2/ibcs2_ioctl.c
	${NORMAL_C}

ibcs2_ipc.o: $S/compat/ibcs2/ibcs2_ipc.c
	${NORMAL_C}

ibcs2_misc.o: $S/compat/ibcs2/ibcs2_misc.c
	${NORMAL_C}

ibcs2_signal.o: $S/compat/ibcs2/ibcs2_signal.c
	${NORMAL_C}

ibcs2_socksys.o: $S/compat/ibcs2/ibcs2_socksys.c
	${NORMAL_C}

ibcs2_stat.o: $S/compat/ibcs2/ibcs2_stat.c
	${NORMAL_C}

ibcs2_sysent.o: $S/compat/ibcs2/ibcs2_sysent.c
	${NORMAL_C}

linux_blkio.o: $S/compat/linux/linux_blkio.c
	${NORMAL_C}

linux_cdrom.o: $S/compat/linux/linux_cdrom.c
	${NORMAL_C}

linux_error.o: $S/compat/linux/linux_error.c
	${NORMAL_C}

linux_exec.o: $S/compat/linux/linux_exec.c
	${NORMAL_C}

linux_fdio.o: $S/compat/linux/linux_fdio.c
	${NORMAL_C}

linux_file.o: $S/compat/linux/linux_file.c
	${NORMAL_C}

linux_file64.o: $S/compat/linux/linux_file64.c
	${NORMAL_C}

linux_getcwd.o: $S/compat/linux/linux_getcwd.c
	${NORMAL_C}

linux_hdio.o: $S/compat/linux/linux_hdio.c
	${NORMAL_C}

linux_ioctl.o: $S/compat/linux/linux_ioctl.c
	${NORMAL_C}

linux_ipc.o: $S/compat/linux/linux_ipc.c
	${NORMAL_C}

linux_misc.o: $S/compat/linux/linux_misc.c
	${NORMAL_C}

linux_mount.o: $S/compat/linux/linux_mount.c
	${NORMAL_C}

linux_resource.o: $S/compat/linux/linux_resource.c
	${NORMAL_C}

linux_sched.o: $S/compat/linux/linux_sched.c
	${NORMAL_C}

linux_signal.o: $S/compat/linux/linux_signal.c
	${NORMAL_C}

linux_socket.o: $S/compat/linux/linux_socket.c
	${NORMAL_C}

linux_sysent.o: $S/compat/linux/linux_sysent.c
	${NORMAL_C}

linux_termios.o: $S/compat/linux/linux_termios.c
	${NORMAL_C}

linux_dummy.o: $S/compat/linux/linux_dummy.c
	${NORMAL_C}

linux_machdep.o: $S/arch/i386/i386/linux_machdep.c
	${NORMAL_C}

bsdos_exec.o: $S/compat/bsdos/bsdos_exec.c
	${NORMAL_C}

bsdos_ioctl.o: $S/compat/bsdos/bsdos_ioctl.c
	${NORMAL_C}

bsdos_sysent.o: $S/compat/bsdos/bsdos_sysent.c
	${NORMAL_C}

freebsd_exec.o: $S/compat/freebsd/freebsd_exec.c
	${NORMAL_C}

freebsd_file.o: $S/compat/freebsd/freebsd_file.c
	${NORMAL_C}

freebsd_ioctl.o: $S/compat/freebsd/freebsd_ioctl.c
	${NORMAL_C}

freebsd_misc.o: $S/compat/freebsd/freebsd_misc.c
	${NORMAL_C}

freebsd_ptrace.o: $S/compat/freebsd/freebsd_ptrace.c
	${NORMAL_C}

freebsd_signal.o: $S/compat/freebsd/freebsd_signal.c
	${NORMAL_C}

freebsd_sysent.o: $S/compat/freebsd/freebsd_sysent.c
	${NORMAL_C}

freebsd_machdep.o: $S/arch/i386/i386/freebsd_machdep.c
	${NORMAL_C}

ossaudio.o: $S/compat/ossaudio/ossaudio.c
	${NORMAL_C}

bios.o: $S/arch/i386/i386/bios.c
	${NORMAL_C}

apm.o: $S/arch/i386/i386/apm.c
	${NORMAL_C}

apmcall.o: $S/arch/i386/i386/apmcall.S
	${NORMAL_S}

pcibios.o: $S/arch/i386/pci/pcibios.c
	${NORMAL_C}

pci_intr_fixup.o: $S/arch/i386/pci/pci_intr_fixup.c
	${NORMAL_C}

pci_bus_fixup.o: $S/arch/i386/pci/pci_bus_fixup.c
	${NORMAL_C}

pci_addr_fixup.o: $S/arch/i386/pci/pci_addr_fixup.c
	${NORMAL_C}

opti82c558.o: $S/arch/i386/pci/opti82c558.c
	${NORMAL_C}

opti82c700.o: $S/arch/i386/pci/opti82c700.c
	${NORMAL_C}

piix.o: $S/arch/i386/pci/piix.c
	${NORMAL_C}

sis85c503.o: $S/arch/i386/pci/sis85c503.c
	${NORMAL_C}

via82c586.o: $S/arch/i386/pci/via82c586.c
	${NORMAL_C}

via8231.o: $S/arch/i386/pci/via8231.c
	${NORMAL_C}

amd756.o: $S/arch/i386/pci/amd756.c
	${NORMAL_C}

ali1543.o: $S/arch/i386/pci/ali1543.c
	${NORMAL_C}

cardslot.o: $S/dev/cardbus/cardslot.c
	${NORMAL_C}

cardbus.o: $S/dev/cardbus/cardbus.c
	${NORMAL_C}

cardbus_map.o: $S/dev/cardbus/cardbus_map.c
	${NORMAL_C}

cardbus_exrom.o: $S/dev/cardbus/cardbus_exrom.c
	${NORMAL_C}

rbus.o: $S/dev/cardbus/rbus.c
	${NORMAL_C}

if_xl_cardbus.o: $S/dev/cardbus/if_xl_cardbus.c
	${NORMAL_C}

if_dc_cardbus.o: $S/dev/cardbus/if_dc_cardbus.c
	${NORMAL_C}

if_fxp_cardbus.o: $S/dev/cardbus/if_fxp_cardbus.c
	${NORMAL_C}

if_rl_cardbus.o: $S/dev/cardbus/if_rl_cardbus.c
	${NORMAL_C}

rbus_machdep.o: $S/arch/i386/i386/rbus_machdep.c
	${NORMAL_C}

i82365.o: $S/dev/ic/i82365.c
	${NORMAL_C}

i82365_isa.o: $S/dev/isa/i82365_isa.c
	${NORMAL_C}

i82365_pci.o: $S/dev/pci/i82365_pci.c
	${NORMAL_C}

i82365_isapnp.o: $S/dev/isa/i82365_isapnp.c
	${NORMAL_C}

i82365_isasubr.o: $S/dev/isa/i82365_isasubr.c
	${NORMAL_C}

tcic2.o: $S/dev/ic/tcic2.c
	${NORMAL_C}

tcic2_isa.o: $S/dev/isa/tcic2_isa.c
	${NORMAL_C}

com_puc.o: $S/dev/puc/com_puc.c
	${NORMAL_C}

lpt_puc.o: $S/dev/puc/lpt_puc.c
	${NORMAL_C}

pcmcia.o: $S/dev/pcmcia/pcmcia.c
	${NORMAL_C}

pcmcia_cis.o: $S/dev/pcmcia/pcmcia_cis.c
	${NORMAL_C}

pcmcia_cis_quirks.o: $S/dev/pcmcia/pcmcia_cis_quirks.c
	${NORMAL_C}

if_ep_pcmcia.o: $S/dev/pcmcia/if_ep_pcmcia.c
	${NORMAL_C}

if_ne_pcmcia.o: $S/dev/pcmcia/if_ne_pcmcia.c
	${NORMAL_C}

aic_pcmcia.o: $S/dev/pcmcia/aic_pcmcia.c
	${NORMAL_C}

com_pcmcia.o: $S/dev/pcmcia/com_pcmcia.c
	${NORMAL_C}

wdc_pcmcia.o: $S/dev/pcmcia/wdc_pcmcia.c
	${NORMAL_C}

if_sm_pcmcia.o: $S/dev/pcmcia/if_sm_pcmcia.c
	${NORMAL_C}

if_xe.o: $S/dev/pcmcia/if_xe.c
	${NORMAL_C}

if_wi_pcmcia.o: $S/dev/pcmcia/if_wi_pcmcia.c
	${NORMAL_C}

if_ray.o: $S/dev/pcmcia/if_ray.c
	${NORMAL_C}

if_an_pcmcia.o: $S/dev/pcmcia/if_an_pcmcia.c
	${NORMAL_C}

usb.o: $S/dev/usb/usb.c
	${NORMAL_C}

usbdi.o: $S/dev/usb/usbdi.c
	${NORMAL_C}

usbdi_util.o: $S/dev/usb/usbdi_util.c
	${NORMAL_C}

usb_mem.o: $S/dev/usb/usb_mem.c
	${NORMAL_C}

usb_subr.o: $S/dev/usb/usb_subr.c
	${NORMAL_C}

usb_quirks.o: $S/dev/usb/usb_quirks.c
	${NORMAL_C}

uhub.o: $S/dev/usb/uhub.c
	${NORMAL_C}

uaudio.o: $S/dev/usb/uaudio.c
	${NORMAL_C}

ucom.o: $S/dev/usb/ucom.c
	${NORMAL_C}

ugen.o: $S/dev/usb/ugen.c
	${NORMAL_C}

hid.o: $S/dev/usb/hid.c
	${NORMAL_C}

uhidev.o: $S/dev/usb/uhidev.c
	${NORMAL_C}

uhid.o: $S/dev/usb/uhid.c
	${NORMAL_C}

ukbd.o: $S/dev/usb/ukbd.c
	${NORMAL_C}

ukbdmap.o: $S/dev/usb/ukbdmap.c
	${NORMAL_C}

ums.o: $S/dev/usb/ums.c
	${NORMAL_C}

ulpt.o: $S/dev/usb/ulpt.c
	${NORMAL_C}

umass.o: $S/dev/usb/umass.c
	${NORMAL_C}

umass_quirks.o: $S/dev/usb/umass_quirks.c
	${NORMAL_C}

umass_scsi.o: $S/dev/usb/umass_scsi.c
	${NORMAL_C}

urio.o: $S/dev/usb/urio.c
	${NORMAL_C}

uvisor.o: $S/dev/usb/uvisor.c
	${NORMAL_C}

if_aue.o: $S/dev/usb/if_aue.c
	${NORMAL_C}

if_cue.o: $S/dev/usb/if_cue.c
	${NORMAL_C}

if_kue.o: $S/dev/usb/if_kue.c
	${NORMAL_C}

if_upl.o: $S/dev/usb/if_upl.c
	${NORMAL_C}

if_url.o: $S/dev/usb/if_url.c
	${NORMAL_C}

umodem.o: $S/dev/usb/umodem.c
	${NORMAL_C}

uftdi.o: $S/dev/usb/uftdi.c
	${NORMAL_C}

uplcom.o: $S/dev/usb/uplcom.c
	${NORMAL_C}

ubsa.o: $S/dev/usb/ubsa.c
	${NORMAL_C}

uscanner.o: $S/dev/usb/uscanner.c
	${NORMAL_C}

usscanner.o: $S/dev/usb/usscanner.c
	${NORMAL_C}

if_wi_usb.o: $S/dev/usb/if_wi_usb.c
	${NORMAL_C}

