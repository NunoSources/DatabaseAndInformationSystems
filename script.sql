
BEGIN pkg_condominio.regista_proprietario(200000000,'Masd','M',10,'B'); END;
/
BEGIN pkg_condominio.regista_administrador(200000000,2010); END;
/
VARIABLE result number;
begin
   :result := pkg_condominio.regista_contrato('Aperture Science',
   'Elevadores', 2010,5000);
end;
/
PRINT result;

BEGIN pkg_condominio.regista_autorizacao (200000000,2010,:result); END; 
/



BEGIN pkg_condominio.remove_autorizacao (200000000,2010,:result); END;
/
BEGIN pkg_condominio.remove_contrato(:result); END;
/
BEGIN pkg_condominio.remove_administrador (200000000,2010); END;
/
BEGIN pkg_condominio.remove_proprietario(200000000); END;
/
