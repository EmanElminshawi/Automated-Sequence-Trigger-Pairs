set serveroutput on 
declare
   cursor trig_seq_cursor is
   select uc.constraint_name,uc.table_name ,ucc.column_name from user_constraints uc ,user_cons_columns ucc , user_objects uo , user_tab_columns utc
   where ucc.table_name = uc.table_name and
             ucc.constraint_name = uc.constraint_name and
             ucc.table_name = uo.object_name and
             ucc.table_name = utc.table_name and
             utc.column_name = ucc.column_name and
             uc.constraint_type = 'P' and uo.object_type = 'TABLE' and utc.data_type = 'NUMBER';
             
           cursor seq_cursor is
           select sequence_name from user_sequences ;
            
  max_val number(30);
begin
   
--LOOP FOR DROP OLD SEQUENCES :
           for seq_record in seq_cursor  loop
           Execute immediate ' Drop Sequence ' || seq_record.sequence_name ;
           end loop;  
           
-- CREATING SEQUENCES  :   

          for trg_record in trig_seq_cursor loop  
          
          Execute immediate 'SELECT NVL(MAX( '||trg_record.column_name||') , 0) +1 FROM '|| trg_record.table_name into max_val ;
          
          Execute immediate  'CREATE SEQUENCE '||trg_record.table_name||'_SEQ  START WITH '||max_val ;

          Execute immediate 
          'CREATE OR REPLACE TRIGGER ' || trg_record.table_name||'_TRG  
          BEFORE INSERT ON '||trg_record.table_name||'
          FOR EACH ROW
          BEGIN
                       :NEW.'||trg_record.column_name||' :='||trg_record.table_name||'_SEQ.NEXTVAL; 
                       END;';
           
          end loop;   
          end;
