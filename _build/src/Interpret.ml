open Language

(* Interpreter for expressions *)
module Expr =
  struct

    open Expr

    let rec eval expr st = 
      let eval' e = eval e st in
      match expr with
      | Var   x     -> st x
      | Const z     -> z
      | Add  (x, y) -> eval' x + eval' y
      | Mul  (x, y) -> eval' x * eval' y
      | Sub  (x, y) -> eval' x - eval' y
      | Div  (x, y) -> eval' x / eval' y
      | Mod  (x, y) -> eval' mod eval' y
      | And  (x, y) -> if( (eval' x) == 1 && (eval' y) == 1) 
		               then 1 
		       else 0
      | Or   (x, y) -> if( (eval' x) == 0 && (eval' y) == 0)
		           then 0
		       else 1
      | Equals (x, y) -> if( (eval' x) == (eval' y))
	                      then 1
			 else 0
      | NotEquals (x, y) -> if( (eval' x) == (eval' y))
	                        then 0
			    else 1
      | Greater  (x, y) -> if( (eval' x) > (eval' y))
	                       then 1
			   else 0
      | Less  (x, y) -> if( (eval' x) < (eval' y))
	                    then 1
			else 0
      | GreaterEquals  (x, y) -> if( (eval' x) < (eval' y))
	                             then 0
				 else 1
      | LessEquals  (x, y) -> if( (eval' x) > (eval' y))
	                          then 0
			      else 1


  end

(* Interpreter for statements *)
module Stmt =
  struct

    open Stmt

    (* State update primitive *) 
    let update st x v = fun y -> if y = x then v else st y 
      
    let rec eval stmt ((st, input, output) as conf) =
      match stmt with
      | Skip          -> conf
      | Assign (x, e) -> (update st x (Expr.eval e st), input, output)
      | Read    x     -> 
	  let z :: input' = input in
	  (update st x z, input', output)
      | Write   e     -> (st, input, output @ [Expr.eval e st])
      | Seq (s1, s2)  -> eval s1 conf |> eval s2 
      | If (expr, then_part, else_part) ->
            if (Expr.eval expr st) != 0
                 then eval then_part conf
            else eval else_part conf
      | While (expr, value) ->
           let rec loop expr' value' ( (st', _, _) as conf') =
               if (Expr.eval expr' st') != 0
                  then loop expr' value' (eval value' conf')
               else conf'
           in
           loop expr value conf    
      | Until (value, expr) ->
            let rec loop expr' value' conf' = 
                let (st_new, _, _) as conf_new = eval value' conf' in
                if (Expr.eval expr' st_new) == 0
                     then loop expr' value' conf_new
                else conf_new
            in
            loop expr value c
  end

module Program =
  struct

    let eval p input = 
      let (_, _, output) = 
	Stmt.eval p ((fun _ -> failwith "undefined variable"), input, []) 
      in
      output

  end
